import SwiftUI

// LociStoa redesign: the panels that slide up from the bottom.
//   LSContactSheet    one person's details
//   LSEmergencySheet  the full list of emergency numbers
//   LSSearchSheet     search across people, offices, tutoring, orgs, lingo, and tools
// (The Add task and Add class panels are in LSPlannerScreen.swift.)

// MARK: - Contact details

struct LSContactSheet: View {
    @EnvironmentObject var store: LSStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let person = store.currentPerson {
                let saved = store.isFav(person)
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 14) {
                        Text(person.initials)
                            .font(.ls(22, .bold))
                            .foregroundStyle(store.p.onDeep)
                            .frame(width: 64, height: 64)
                            .background(store.p.deep)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.ls(22, .heavy))
                            Text(person.role)
                                .font(.ls(14))
                                .foregroundStyle(store.p.sub)
                        }
                        .padding(.top, 4)
                        Spacer(minLength: 0)
                        LSCloseButton()
                    }

                    HStack(spacing: 8) {
                        LSActionTile(title: "Email", icon: "envelope", filled: true) {
                            // Opens the phone's mail app with this person's address filled in.
                            if let url = URL(string: "mailto:" + person.email) {
                                openURL(url)
                            }
                        }
                        LSActionTile(title: "Map", icon: "mappin.and.ellipse", filled: false) {
                            store.openMap()
                        }
                        LSActionTile(title: saved ? "Saved" : "Save", icon: saved ? "star.fill" : "star", filled: false) {
                            store.toggleFav(person)
                        }
                    }

                    LSInfoRows(rows: [
                        ("Department", person.dept),
                        ("Office", person.office),
                        ("Email", person.email),
                    ])

                    Button {
                        store.openPeople(.depts, dept: person.dept)
                    } label: {
                        HStack {
                            Text("See the whole department").font(.ls(15, .bold))
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.ls(14, .semibold))
                                .foregroundStyle(store.p.sub)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 52)
                        .background(store.p.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LSPressStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
        }
        .background(store.p.card)
    }
}

/// One of the three square buttons on the contact panel.
struct LSActionTile: View {
    @EnvironmentObject var store: LSStore
    let title: String
    let icon: String
    let filled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.ls(18, .semibold))
                Text(title).font(.ls(12.5, .bold))
            }
            .foregroundStyle(filled ? store.p.onAccent : store.p.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(filled ? store.p.accent : store.p.tint)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(LSPressStyle())
    }
}

// MARK: - Emergency numbers

struct LSEmergencySheet: View {
    @EnvironmentObject var store: LSStore
    // This panel keeps its own "which number was tapped" so the confirmation shows on top of it.
    @State private var confirm: LSNumber?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                LSSheetHeader(title: "Emergency numbers")

                VStack(spacing: 10) {
                    ForEach(store.data.numbers) { number in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(number.number)
                                    .font(.ls(22, .heavy))
                                    .monospacedDigit()
                                Text(number.label).font(.ls(13.5, .semibold))
                            }
                            Spacer(minLength: 0)
                            Button {
                                confirm = number
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "phone.fill").font(.ls(14))
                                    Text("Call").font(.ls(15, .bold))
                                }
                                .foregroundStyle(number.primary ? LSPalette.danger : Color.white)
                                .padding(.horizontal, 18)
                                .frame(height: 48)
                                .background(number.primary ? Color.white : LSPalette.danger)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(LSPressStyle())
                            .accessibilityLabel("Call " + number.label)
                        }
                        .foregroundStyle(number.primary ? Color.white : store.p.ink)
                        .padding(.leading, 16)
                        .padding(.trailing, 10)
                        .padding(.vertical, 10)
                        .frame(minHeight: 68)
                        .background(number.primary ? LSPalette.danger : store.p.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(number.primary ? LSPalette.danger : Color(lsHex: 0xEBC4C0), lineWidth: 1.5)
                        )
                    }
                }

                Text("Calling is turned off in this prototype. Numbers come from mtu.edu pages, checked November 2026.")
                    .font(.ls(12.5))
                    .foregroundStyle(store.p.sub)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
        .background(store.p.card)
        .modifier(LSCallConfirm(number: $confirm))
    }
}

// MARK: - Search

struct LSSearchSheet: View {
    @EnvironmentObject var store: LSStore

    private var nothingFound: Bool {
        !store.searchIsIdle
            && store.lingoHits.isEmpty && store.officeHits.isEmpty && store.centerHits.isEmpty
            && store.peopleHits.isEmpty && store.orgHits.isEmpty && store.toolHits.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                LSSearchField(placeholder: "Search people, places, and tools", text: $store.query, bold: true, autoFocus: true)
                Button {
                    store.sheet = nil
                } label: {
                    Text("Cancel")
                        .font(.ls(15, .bold))
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(LSPressStyle())
            }

            if store.searchIsIdle {
                VStack(alignment: .leading, spacing: 10) {
                    LSCaps(text: "Try")
                    LSChipRow {
                        ForEach(["Transcript", "Parking", "Tutoring", "MUB"], id: \.self) { word in
                            LSChip(label: word, on: false) {
                                store.query = word
                            }
                        }
                    }
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    if !store.lingoHits.isEmpty {
                        LSHitSection(title: "Campus lingo") {
                            ForEach(Array(store.lingoHits.enumerated()), id: \.element.id) { index, hit in
                                if index > 0 {
                                    LSRule()
                                }
                                LSLingoRow(hit: hit)
                            }
                        }
                    }
                    if !store.officeHits.isEmpty {
                        LSHitSection(title: "Offices that can help") {
                            ForEach(Array(store.officeHits.enumerated()), id: \.element.id) { index, office in
                                if index > 0 {
                                    LSRule()
                                }
                                LSNavRow(title: office.name, sub: office.goHereFor) {
                                    store.openPeople(.help, office: office.id)
                                }
                            }
                        }
                    }
                    if !store.centerHits.isEmpty {
                        LSHitSection(title: "Tutoring") {
                            ForEach(Array(store.centerHits.enumerated()), id: \.element.id) { index, center in
                                if index > 0 {
                                    LSRule()
                                }
                                LSNavRow(title: center.name, sub: store.place(center)) {
                                    store.openPeople(.tutor, center: center.id)
                                }
                            }
                        }
                    }
                    if !store.peopleHits.isEmpty {
                        LSHitSection(title: "People") {
                            ForEach(Array(store.peopleHits.enumerated()), id: \.element.id) { index, person in
                                if index > 0 {
                                    LSRule()
                                }
                                LSPersonRow(person: person, chevron: false)
                            }
                        }
                    }
                    if !store.orgHits.isEmpty {
                        LSHitSection(title: "Student organizations") {
                            ForEach(Array(store.orgHits.enumerated()), id: \.element.id) { index, org in
                                if index > 0 {
                                    LSRule()
                                }
                                LSNavRow(title: org.name, sub: org.category) {
                                    store.openPeople(.orgs, org: org.id)
                                }
                            }
                        }
                    }
                    if !store.toolHits.isEmpty {
                        LSHitSection(title: "Places & tools") {
                            ForEach(Array(store.toolHits.enumerated()), id: \.element.id) { index, tool in
                                if index > 0 {
                                    LSRule()
                                }
                                LSToolRow(tool: tool)
                            }
                        }
                    }
                    if nothingFound {
                        LSEmptyCard(title: "Nothing found",
                                    sub: "Try a name, a department, something you need help with, or a building nickname.")
                    }
                }
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .background(store.p.bg.ignoresSafeArea())
    }
}

/// A titled white card holding one group of search results.
struct LSHitSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LSCaps(text: title)
            LSCard(padding: 0, radius: 20) {
                Group {
                    content
                }
                .padding(.horizontal, 14)
            }
        }
    }
}

/// "MUB" -> Memorial Union Building, and a jump to it on the map.
struct LSLingoRow: View {
    @EnvironmentObject var store: LSStore
    let hit: LSLingo

    var body: some View {
        Button {
            store.openMap(building: hit.buildingID)
        } label: {
            HStack(spacing: 12) {
                Text(hit.term)
                    .font(.ls(13, .bold))
                    .foregroundStyle(store.p.onDeep)
                    .padding(.horizontal, 10)
                    .frame(minWidth: 40)
                    .frame(height: 40)
                    .background(store.p.deep)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 0) {
                    Text(hit.meaning)
                        .font(.ls(15, .bold))
                        .multilineTextAlignment(.leading)
                    Text("\"\(hit.term)\" is campus lingo for this · Show on map")
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
            .frame(minHeight: 62)
            .contentShape(Rectangle())
        }
        .buttonStyle(LSPressStyle())
    }
}

struct LSToolRow: View {
    @EnvironmentObject var store: LSStore
    let tool: LSTool

    var body: some View {
        Button {
            store.run(tool)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: tool.icon)
                    .font(.ls(17, .semibold))
                    .frame(width: 40, height: 40)
                    .background(store.p.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 0) {
                    Text(tool.label).font(.ls(15, .bold))
                    Text(tool.sub)
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(LSPressStyle())
    }
}
