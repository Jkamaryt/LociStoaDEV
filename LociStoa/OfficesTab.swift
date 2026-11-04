import SwiftUI

/// Offices tab: the emergency row, category filters, and every campus office.
struct OfficesTab: View {
    let query: String
    @State private var filter = "All"

    private let offices = DirectoryData.offices
    private let categories = DirectoryData.officeCategories

    /// Offices that pass the chip filter and contain every word typed in search.
    private var results: [Office] {
        let words = DirectoryData.searchWords(query)
        return offices.filter { office in
            (filter == "All" || office.category == filter)
                && words.allSatisfy { office.searchText.contains($0) }
        }
    }

    /// True when nothing is typed and no chip is picked: show everything grouped.
    private var isBrowsing: Bool { query.isEmpty && filter == "All" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if isBrowsing {
                    EmergencySlider()
                }

                filterChips

                VStack(alignment: .leading, spacing: 12) {
                    if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                    } else if isBrowsing {
                        ForEach(categories, id: \.self) { category in
                            let inCategory = results.filter { $0.category == category }
                            if !inCategory.isEmpty {
                                SectionHeader(title: category, count: inCategory.count)
                                ForEach(inCategory) { office in
                                    officeLink(office)
                                }
                            }
                        }
                    } else {
                        Text(results.count == 1 ? "1 office" : "\(results.count) offices")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(lociAccent.opacity(0.8))
                            .padding(.horizontal, 4)
                        ForEach(results) { office in
                            officeLink(office)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 28)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All"] + categories, id: \.self) { name in
                    FilterChip(title: name, count: count(for: name), isSelected: filter == name) {
                        filter = name
                    }
                }
            }
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
    }

    private func count(for category: String) -> Int {
        category == "All" ? offices.count : offices.filter { $0.category == category }.count
    }

    private func officeLink(_ office: Office) -> some View {
        NavigationLink {
            OfficeDetailView(office: office)
        } label: {
            OfficeRow(office: office, query: query)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pieces used on the Offices tab

/// One office card in the list.
struct OfficeRow: View {
    let office: Office
    var query: String = ""

    var body: some View {
        HStack(spacing: 14) {
            CategoryIcon(category: office.category, size: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(office.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(office.goHereFor)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if let hint = matchHint {
                    Text(hint)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(lociAccent)
                }
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

    /// When the search matched a keyword instead of the name, say which one.
    /// Example: searching "therapy" shows "Matches “therapy”" on the counseling center.
    private var matchHint: String? {
        let words = DirectoryData.searchWords(query)
        guard let first = words.first else { return nil }
        let visible = (office.name + " " + office.goHereFor + " " + office.category).lowercased()
        if words.allSatisfy({ visible.contains($0) }) { return nil }
        if let keyword = office.keywords?.first(where: { $0.lowercased().contains(first) }) {
            return "Matches “\(keyword)”"
        }
        return "Matches office details"
    }
}

/// The rounded square with an icon for the office's category.
struct CategoryIcon: View {
    let category: String
    var size: CGFloat = 46

    var body: some View {
        Image(systemName: DirectoryData.icon(for: category))
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(lociAccent)
            .frame(width: size, height: size)
            .background(lociAccent.opacity(0.2), in: RoundedRectangle(cornerRadius: size * 0.34, style: .continuous))
    }
}

/// A pill-shaped filter button, like "Health 6".
struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                Text("\(count)").opacity(0.7)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .foregroundStyle(isSelected ? Color.white : lociAccent)
            .background(isSelected ? lociAccent : lociAccent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// A purple heading over a group of cards, like "Health 6".
struct SectionHeader: View {
    let title: String
    var count: Int? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(lociAccent)
            if let count {
                Text("\(count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(lociAccent.opacity(0.6))
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 4)
    }
}

// MARK: - Office detail page

/// The page that slides in after tapping an office.
struct OfficeDetailView: View {
    let office: Office

    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header

                    if let keywords = office.keywords, !keywords.isEmpty {
                        tags(Array(keywords.prefix(8)))
                    }

                    if let note = office.note {
                        Text(note)
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    infoCard

                    if let phone = office.phone, let url = DirectoryData.phoneURL(phone) {
                        Link(destination: url) {
                            Label("Call \(phone)", systemImage: "phone.fill")
                        }
                        .buttonStyle(ModernButtonStyle())
                    }

                    if let place = office.mapSearch, let url = DirectoryData.mapsURL(place) {
                        Link(destination: url) {
                            Label("Open in Maps", systemImage: "map.fill")
                        }
                        .buttonStyle(ModernButtonStyle())
                    }

                    // Staff from the People tab who work in this office: the first 5,
                    // then the department rows to see everyone.
                    if !officeStaff.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "People in this office", count: officeStaff.count)
                            ForEach(officeStaff.prefix(5)) { person in
                                PersonLink(person: person)
                            }
                            if officeStaff.count > 5 {
                                DepartmentList(departments: officeDepartments)
                            }
                        }
                    }

                    if let website = office.website {
                        Text("Source: \(DirectoryData.shortWebAddress(website)), collected October 2026.")
                            .font(.caption)
                            .foregroundStyle(lociAccent.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Office")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// The People-tab departments linked to this office (from "departments" in offices.json).
    private var officeDepartments: [Department] {
        (office.departments ?? []).compactMap { DirectoryData.departmentByRaw[$0] }
    }

    private var officeStaff: [Person] {
        officeDepartments.flatMap { DirectoryData.peopleByDepartment[$0.raw] ?? [] }
    }

    private var header: some View {
        VStack(spacing: 10) {
            CategoryIcon(category: office.category, size: 76)
            Text(office.category.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(lociAccent.opacity(0.8))
            Text(office.name)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(lociAccent)
                .multilineTextAlignment(.center)
            Text(office.subtitle ?? office.goHereFor)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func tags(_ words: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(words, id: \.self) { word in
                    Text(word)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(lociAccent)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 4)
                        .background(lociAccent.opacity(0.12), in: Capsule())
                }
            }
        }
    }

    /// The white box with Location, Hours, Phone, Email and Website.
    private var infoCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(infoItems.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 52)
                }
                InfoRow(item: item)
            }
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private var infoItems: [InfoItem] {
        var items: [InfoItem] = []
        if let value = office.location {
            items.append(InfoItem(icon: "mappin.and.ellipse", label: "Location", value: value))
        }
        if let value = office.hours {
            items.append(InfoItem(icon: "clock", label: "Hours", value: value))
        }
        if let value = office.phone {
            items.append(InfoItem(icon: "phone", label: "Phone", value: value, url: DirectoryData.phoneURL(value)))
        }
        if let second = office.phone2 {
            items.append(InfoItem(icon: "phone", label: second.label, value: second.number, url: DirectoryData.phoneURL(second.number)))
        }
        if let value = office.text {
            items.append(InfoItem(icon: "message", label: "Text", value: value, url: DirectoryData.textURL(value)))
        }
        if let value = office.email {
            items.append(InfoItem(icon: "envelope", label: "Email", value: value, url: URL(string: "mailto:" + value)))
        }
        if let value = office.website {
            items.append(InfoItem(icon: "globe", label: "Website", value: DirectoryData.shortWebAddress(value), url: URL(string: value)))
        }
        return items
    }
}

/// One line in the info box. If it has a link, tapping it calls, texts, emails or opens the site.
struct InfoItem {
    let icon: String
    let label: String
    let value: String
    var url: URL? = nil
}

struct InfoRow: View {
    let item: InfoItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .foregroundStyle(lociAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let url = item.url {
                    Link(item.value, destination: url)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(item.value)
                        .font(.body)
                        .textSelection(.enabled)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
