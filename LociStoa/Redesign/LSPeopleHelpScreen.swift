import SwiftUI

// LociStoa redesign: the People tab and the Help tab.
// They share one screen because they work the same way: a title, a switch between views,
// then either a searchable list or the page for one item.
//   People tab: Directory, Departments, Student orgs
//   Help tab:   Get help (offices), Tutoring (learning centers)

struct LSPeopleHelpScreen: View {
    @EnvironmentObject var store: LSStore

    private var segments: [(id: String, label: String)] {
        if store.tab == .help {
            return [("help", "Get help"), ("tutor", "Tutoring")]
        }
        return [("dir", "Directory"), ("depts", "Departments"), ("orgs", "Student orgs")]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                LSTitle(text: store.tab == .help ? "Help" : "People")

                if store.tab == .help {
                    LSEmergencyChips()
                }

                LSSegmented(items: segments, selected: store.pane.rawValue) { id in
                    if let pane = LSPane(rawValue: id) {
                        store.pickPane(pane)
                    }
                }

                switch store.pane {
                case .dir:
                    LSDirectoryPane()
                case .depts:
                    if store.dept == nil {
                        LSDeptListPane()
                    } else {
                        LSDeptPage()
                    }
                case .orgs:
                    if let org = store.currentOrg {
                        LSOrgPage(org: org)
                    } else {
                        LSOrgListPane()
                    }
                case .help:
                    if let office = store.currentOffice {
                        LSOfficePage(office: office)
                    } else {
                        LSHelpListPane()
                    }
                case .tutor:
                    if let center = store.currentCenter {
                        LSCenterPage(center: center)
                    } else {
                        LSTutorListPane()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Emergency numbers (top of the Help tab)

struct LSEmergencyChips: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        LSChipRow {
            ForEach(store.data.numbers) { number in
                Button {
                    store.confirmNumber = number
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "phone.fill")
                            .font(.ls(13))
                            .foregroundStyle(LSPalette.danger)
                        Text(number.chip).font(.ls(14, .semibold))
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 14)
                    .frame(height: 44)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(store.p.line, lineWidth: 1.5))
                }
                .buttonStyle(LSPressStyle())
                .accessibilityLabel("Call " + number.label)
            }
        }
    }
}

// MARK: - Directory

struct LSDirectoryPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let matches = store.dirMatches
        VStack(alignment: .leading, spacing: 14) {
            LSSearchField(placeholder: "Name, title, or department", text: $store.dirQuery)

            LSChipRow {
                ForEach(["All", "Faculty", "Staff"], id: \.self) { name in
                    LSChip(label: name, on: store.filter == name) {
                        store.filter = name
                    }
                }
            }

            Text(store.countText(matches.count, one: "person", many: "people"))
                .font(.ls(13, .semibold))
                .foregroundStyle(store.p.sub)

            if matches.isEmpty {
                LSCard(padding: 20) {
                    Text("No one matches that search").font(.ls(19, .bold))
                    Text("Check the spelling, or try a department or job title.")
                        .font(.ls(14))
                        .foregroundStyle(store.p.sub)
                        .padding(.top, 6)
                    Button {
                        store.dirQuery = ""
                        store.filter = "All"
                    } label: {
                        Text("Clear search")
                            .font(.ls(14, .bold))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 18)
                            .frame(height: 44)
                            .background(store.p.accent)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(LSPressStyle())
                    .padding(.top, 12)
                }
            } else {
                LSCard(padding: 0) {
                    ForEach(Array(matches.prefix(LSStore.cap).enumerated()), id: \.element.id) { index, person in
                        if index > 0 {
                            LSRule()
                        }
                        LSPersonRow(person: person)
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
    }
}

// MARK: - Departments

struct LSDeptListPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let matches = store.deptMatches
        VStack(alignment: .leading, spacing: 14) {
            LSSearchField(placeholder: "Department or office name", text: $store.deptQuery)

            Text(store.countText(matches.count, one: "department", many: "departments"))
                .font(.ls(13, .semibold))
                .foregroundStyle(store.p.sub)

            if matches.isEmpty {
                LSEmptyCard(title: "No department matches", sub: "Try a shorter name, like \"business\" or \"library\".")
            } else {
                LSCard(padding: 0) {
                    ForEach(Array(matches.prefix(LSStore.cap).enumerated()), id: \.element.id) { index, dept in
                        if index > 0 {
                            LSRule()
                        }
                        LSNavRow(title: dept.name, sub: "\(dept.count) \(dept.count == 1 ? "person" : "people")") {
                            store.dept = dept.name
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
    }
}

struct LSDeptPage: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSBackButton(label: "All departments") {
                store.dept = nil
            }
            if !store.deptCategory.isEmpty {
                LSCaps(text: store.deptCategory)
            }
            Text(store.dept ?? "").font(.ls(24, .heavy))
            if !store.deptReportsTo.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Reports up to:")
                        .font(.ls(14))
                        .foregroundStyle(store.p.sub)
                    Text(store.deptReportsTo)
                        .font(.ls(14, .bold))
                }
            }

            LSCard(padding: 0) {
                ForEach(store.deptPeople) { row in
                    if let head = row.head {
                        LSCaps(text: head)
                            .padding(.top, 14)
                            .padding(.bottom, 4)
                    } else {
                        LSRule()
                    }
                    LSPersonRow(person: row.person, showDept: false)
                }
                .padding(.horizontal, 14)
            }
        }
    }
}

// MARK: - Get help (offices)

/// A list split into groups with a small heading above each group.
struct LSGroupedList: View {
    let rows: [LSGroupRow]
    let onPick: (String) -> Void

    var body: some View {
        LSCard(padding: 0) {
            ForEach(rows) { row in
                if let head = row.head {
                    LSCaps(text: head)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                } else {
                    LSRule()
                }
                LSNavRow(title: row.title, sub: row.sub) {
                    onPick(row.id)
                }
            }
            .padding(.horizontal, 14)
        }
    }
}

struct LSHelpListPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let rows = store.helpRows
        VStack(alignment: .leading, spacing: 14) {
            Text("Tell us what you need and we'll point you to the right office.")
                .font(.ls(15))
                .foregroundStyle(store.p.sub)
            LSSearchField(placeholder: "Try transcript or parking", text: $store.helpQuery)

            if rows.isEmpty {
                LSEmptyCard(title: "No office matches that",
                            sub: "Try a different word, or ask the Dean of Students office. They can point you anywhere.")
            } else {
                LSGroupedList(rows: rows) { id in
                    // The Tutoring row opens the tutoring list instead of an office page.
                    if id == "learning" {
                        store.pickPane(.tutor)
                    } else {
                        store.officeID = id
                    }
                }
            }
        }
    }
}

struct LSOfficePage: View {
    @EnvironmentObject var store: LSStore
    let office: LSOffice

    private var rows: [(label: String, value: String)] {
        let all: [(label: String, value: String)] = [
            ("Location", office.location),
            ("Hours", office.hours),
            ("Email", office.email),
            ("Main line", office.phone),
        ]
        return all.filter { !$0.value.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSBackButton(label: "All topics") {
                store.officeID = nil
            }
            LSCaps(text: office.category)
            Text(office.name).font(.ls(24, .heavy))
            Text(office.goHereFor)
                .font(.ls(15))
                .foregroundStyle(store.p.sub)

            if !rows.isEmpty {
                LSInfoRows(rows: rows).padding(.top, 4)
            }
            if !office.note.isEmpty {
                Text(office.note)
                    .font(.ls(13.5))
                    .foregroundStyle(store.p.sub)
            }
            LSWebButton(title: "Open website", address: office.website)
            if let dept = office.departments.first {
                LSBigButton(title: "See people in this office") {
                    store.openPeople(.depts, dept: dept)
                }
            }
        }
    }
}

// MARK: - Tutoring (learning centers)

struct LSTutorListPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let rows = store.tutorRows
        VStack(alignment: .leading, spacing: 14) {
            Text("Free tutoring and coaching from MTU, by subject.")
                .font(.ls(15))
                .foregroundStyle(store.p.sub)
            LSSearchField(placeholder: "Subject, course, or center", text: $store.tutorQuery)

            if rows.isEmpty {
                LSEmptyCard(title: "No center matches that",
                            sub: "Try a subject like math or writing, or a course code like PH.")
            } else {
                LSGroupedList(rows: rows) { id in
                    store.centerID = id
                }
            }
        }
    }
}

struct LSCenterPage: View {
    @EnvironmentObject var store: LSStore
    let center: LSCenter

    private var rows: [(label: String, value: String)] {
        let all: [(label: String, value: String)] = [
            ("Location", center.room.isEmpty ? center.building : center.building + ", " + center.room),
            ("Hours", center.hours.isEmpty ? "" : center.hours + (center.term.isEmpty ? "" : " (" + center.term + ")")),
            ("How to get help", center.how),
            ("Contact", center.contact),
            ("Email", center.email),
            ("Phone", center.phone),
        ]
        return all.filter { !$0.value.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSBackButton(label: "All tutoring") {
                store.centerID = nil
            }
            LSCaps(text: center.category)
            Text(center.name).font(.ls(24, .heavy))
            Text(center.subjects)
                .font(.ls(15))
                .foregroundStyle(store.p.sub)

            if !rows.isEmpty {
                LSInfoRows(rows: rows).padding(.top, 4)
            }
            if !center.notes.isEmpty {
                Text(center.notes)
                    .font(.ls(13.5))
                    .foregroundStyle(store.p.sub)
            }
            LSWebButton(title: "Book an appointment", address: center.book, filled: true)
            LSWebButton(title: "Open website", address: center.website)
            if !center.mapBuilding.isEmpty {
                LSBigButton(title: "Show on map", soft: true) {
                    store.openMap(building: center.mapBuilding)
                }
            }
        }
    }
}

// MARK: - Student orgs

struct LSOrgListPane: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        let matches = store.orgMatches
        VStack(alignment: .leading, spacing: 14) {
            LSSearchField(placeholder: "Organization name", text: $store.orgQuery)

            LSChipRow {
                ForEach(["All"] + store.data.orgCategories, id: \.self) { name in
                    LSChip(label: name, on: store.orgCat == name) {
                        store.orgCat = name
                    }
                }
            }

            Text(store.countText(matches.count, one: "organization", many: "organizations"))
                .font(.ls(13, .semibold))
                .foregroundStyle(store.p.sub)

            if matches.isEmpty {
                LSEmptyCard(title: "No organization matches", sub: "Try a shorter name or a different category.")
            } else {
                LSCard(padding: 0) {
                    ForEach(Array(matches.prefix(LSStore.cap).enumerated()), id: \.element.id) { index, org in
                        if index > 0 {
                            LSRule()
                        }
                        Button {
                            store.orgIndex = org.id
                        } label: {
                            HStack(spacing: 12) {
                                LSOrgLogo(org: org, size: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(org.name)
                                        .font(.ls(15, .bold))
                                        .multilineTextAlignment(.leading)
                                    Text(org.category)
                                        .font(.ls(13))
                                        .foregroundStyle(store.p.sub)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .font(.ls(14, .semibold))
                                    .foregroundStyle(store.p.sub)
                            }
                            .padding(.vertical, 6)
                            .frame(minHeight: 64)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(LSPressStyle())
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
    }
}

struct LSOrgPage: View {
    @EnvironmentObject var store: LSStore
    let org: LSOrg

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LSBackButton(label: "All organizations") {
                store.orgIndex = nil
            }
            LSOrgLogo(org: org, size: 72)
            LSCaps(text: org.category)
            Text(org.name).font(.ls(24, .heavy))
            Text(org.desc).font(.ls(15))

            if !org.email.isEmpty {
                LSInfoRows(rows: [("Email", org.email)]).padding(.top, 4)
            }
            LSWebButton(title: "Open website", address: org.site)
        }
    }
}
