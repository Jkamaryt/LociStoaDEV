import SwiftUI

/// People tab: browse 943 faculty and staff by department, or search for anyone.
struct PeopleTab: View {
    let query: String
    /// Search results show 50 people at a time, with a "Show more" button.
    @State private var shownCount = 50
    @Environment(PinStore.self) private var pins

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if query.isEmpty {
                    browse
                } else {
                    searchResults
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .onChange(of: query) {
            shownCount = 50
        }
    }

    /// No search typed: pinned people, then the A–Z list of departments.
    @ViewBuilder private var browse: some View {
        let pinned = pins.people
        SectionHeader(title: "Pinned", count: pinned.isEmpty ? nil : pinned.count)
        if pinned.isEmpty {
            PinnedTip(text: "Pin people you contact often, like your advisor. Open them and tap the pin.")
        } else {
            ForEach(pinned) { person in
                PersonLink(person: person)
            }
        }

        SectionHeader(title: "Browse by department", count: DirectoryData.departments.count)
        ForEach(DirectoryData.departmentGroups) { group in
            Text(group.letter)
                .font(.footnote.weight(.bold))
                .foregroundStyle(lociAccent.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.top, 4)
            DepartmentList(departments: group.departments)
        }
    }

    /// Something typed: matching departments first, then matching people.
    @ViewBuilder private var searchResults: some View {
        let words = DirectoryData.searchWords(query)
        let departments = DirectoryData.departments.filter { department in
            let text = (department.name + " " + department.raw).lowercased()
            return words.allSatisfy { text.contains($0) }
        }
        let people = DirectoryData.people.filter { person in
            words.allSatisfy { person.searchText.contains($0) }
        }

        if departments.isEmpty && people.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            Text(summary(people: people.count, departments: departments.count))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(lociAccent.opacity(0.8))
                .padding(.horizontal, 4)

            if !departments.isEmpty {
                SectionHeader(title: "Departments", count: departments.count)
                DepartmentList(departments: departments)
            }

            if !people.isEmpty {
                if !departments.isEmpty {
                    SectionHeader(title: "People", count: people.count)
                }
                ForEach(people.prefix(shownCount)) { person in
                    PersonLink(person: person)
                }
                if people.count > shownCount {
                    let left = people.count - shownCount
                    Button("Show \(min(50, left)) more of \(left)") {
                        shownCount += 50
                    }
                    .buttonStyle(CapsuleButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func summary(people: Int, departments: Int) -> String {
        var text = people == 1 ? "1 person" : "\(people) people"
        if departments > 0 {
            text += departments == 1 ? " and 1 department" : " and \(departments) departments"
        }
        return text
    }
}

// MARK: - Pieces used on the People tab

/// A white box of department rows. Tapping a row opens that department.
struct DepartmentList: View {
    let departments: [Department]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(departments.enumerated()), id: \.offset) { index, department in
                if index > 0 {
                    Divider().padding(.leading, 16)
                }
                NavigationLink {
                    DepartmentView(department: department)
                } label: {
                    DepartmentRow(department: department)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

struct DepartmentRow: View {
    let department: Department

    var body: some View {
        HStack(spacing: 10) {
            Text(department.name)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 8)
            Text("\(department.count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(lociAccent.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())   // the whole row is tappable, not just the text
    }
}

/// A person's card that opens their page.
struct PersonLink: View {
    let person: Person

    var body: some View {
        NavigationLink {
            PersonDetailView(person: person)
        } label: {
            PersonRow(person: person)
        }
        .buttonStyle(.plain)
    }
}

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 14) {
            InitialsCircle(initials: person.initials, size: 46)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(person.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let degree = person.degree {
                        Text(degree)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)

                Text(person.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(lociAccent.opacity(0.6))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

/// The purple circle with someone's initials.
struct InitialsCircle: View {
    let initials: String
    var size: CGFloat = 46

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
            .foregroundStyle(lociAccent)
            .frame(width: size, height: size)
            .background(lociAccent.opacity(0.2), in: Circle())
    }
}

/// The small purple pill button, used for "Show more".
struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(lociAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(lociAccent.opacity(0.2), in: Capsule())
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: - Department page

/// Everyone in one department, with the department's office at the top if it has one.
struct DepartmentView: View {
    let department: Department

    private var people: [Person] {
        DirectoryData.peopleByDepartment[department.raw] ?? []
    }

    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text(department.count == 1 ? "1 person" : "\(department.count) people")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(lociAccent.opacity(0.8))
                        .padding(.horizontal, 4)

                    if let office = DirectoryData.officeForDepartment[department.raw] {
                        SectionHeader(title: "Office")
                        NavigationLink {
                            OfficeDetailView(office: office)
                        } label: {
                            OfficeRow(office: office)
                        }
                        .buttonStyle(.plain)
                    }

                    let faculty = people.filter { $0.faculty }
                    let staff = people.filter { !$0.faculty }

                    if !faculty.isEmpty {
                        SectionHeader(title: "Faculty", count: faculty.count)
                        ForEach(faculty) { person in
                            PersonLink(person: person)
                        }
                    }
                    if !staff.isEmpty {
                        SectionHeader(title: "Staff", count: staff.count)
                        ForEach(staff) { person in
                            PersonLink(person: person)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(department.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Person page

/// The page that slides in after tapping a person.
struct PersonDetailView: View {
    let person: Person

    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    infoCard

                    if let url = URL(string: "mailto:" + person.email) {
                        Link(destination: url) {
                            Label("Email \(person.firstName)", systemImage: "envelope.fill")
                        }
                        .buttonStyle(ModernButtonStyle())
                    }

                    if let place = person.mapSearch, let url = DirectoryData.mapsURL(place) {
                        Link(destination: url) {
                            Label("Find their building", systemImage: "map.fill")
                        }
                        .buttonStyle(ModernButtonStyle())
                    }

                    if let department = DirectoryData.departmentByRaw[person.departmentRaw], department.count > 1 {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Same department")
                            DepartmentList(departments: [department])
                        }
                    }

                    Text("Source: Michigan Tech employee listing, Sept. 14, 2026. Phone numbers are not shown.")
                        .font(.caption)
                        .foregroundStyle(lociAccent.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Person")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PinButton(key: person.pinKey)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            InitialsCircle(initials: person.initials, size: 76)
            Text(person.role.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(lociAccent.opacity(0.8))
            Text(person.degree.map { "\(person.name), \($0)" } ?? person.name)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(lociAccent)
                .multilineTextAlignment(.center)
            if !person.title.isEmpty {
                Text(person.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Department (with a link to its office), office location and email.
    private var infoCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "briefcase")
                    .foregroundStyle(lociAccent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Department")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(person.department)
                        .font(.body)
                }
                Spacer(minLength: 0)
                if let office = DirectoryData.officeForDepartment[person.departmentRaw] {
                    NavigationLink {
                        OfficeDetailView(office: office)
                    } label: {
                        Text("Office")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(lociAccent)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(lociAccent.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if let office = person.office {
                Divider().padding(.leading, 52)
                InfoRow(item: InfoItem(icon: "mappin.and.ellipse", label: "Office", value: office))
            }

            Divider().padding(.leading, 52)
            InfoRow(item: InfoItem(icon: "envelope", label: "Email", value: person.email, url: URL(string: "mailto:" + person.email)))
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
