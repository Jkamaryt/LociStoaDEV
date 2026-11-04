import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Orgs tab: category tiles to browse all 268 student orgs, or search for one.
struct OrgsTab: View {
    let query: String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if query.isEmpty {
                    OrgCategoryGrid()
                } else {
                    searchResults
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }

    @ViewBuilder private var searchResults: some View {
        let words = DirectoryData.searchWords(query)
        let matches = DirectoryData.orgs.filter { org in
            words.allSatisfy { org.searchText.contains($0) }
        }

        if matches.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            Text(matches.count == 1 ? "1 organization" : "\(matches.count) organizations")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(lociAccent.opacity(0.8))
                .padding(.horizontal, 4)
            ForEach(matches) { org in
                OrgLink(org: org, query: query)
            }
        }
    }
}

// MARK: - Category tiles

/// The grid of category tiles. Also shown by the "Browse student orgs" button
/// on the Student Leadership and Involvement office page.
struct OrgCategoryGrid: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Browse by category")
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DirectoryData.orgCategories, id: \.self) { category in
                    NavigationLink {
                        OrgCategoryView(category: category)
                    } label: {
                        CategoryTile(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// One tile: three logos from the category, its name and how many orgs are in it.
struct CategoryTile: View {
    let category: String

    private var orgs: [Org] {
        DirectoryData.orgsByCategory[category] ?? []
    }

    /// Three logos spread across the category, so it isn't always the "A" clubs.
    private var logoSlugs: [String] {
        let withLogos = orgs.filter { OrgLogos.has($0.slug) }
        guard !withLogos.isEmpty else { return [] }
        let picks = [0, 1, 2].map { withLogos[$0 * withLogos.count / 3].slug }
        var seen = Set<String>()
        return picks.filter { seen.insert($0).inserted }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: -9) {
                ForEach(logoSlugs, id: \.self) { slug in
                    if let image = OrgLogos.image(for: slug) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white, lineWidth: 2))
                            .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .frame(height: 30)
            .padding(.bottom, 4)

            Text(category)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Text(orgs.count == 1 ? "1 org" : "\(orgs.count) orgs")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

/// Every org in one category, opened from a tile.
struct OrgCategoryView: View {
    let category: String

    private var orgs: [Org] {
        DirectoryData.orgsByCategory[category] ?? []
    }

    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text(orgs.count == 1 ? "1 organization" : "\(orgs.count) organizations")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(lociAccent.opacity(0.8))
                        .padding(.horizontal, 4)
                    ForEach(orgs) { org in
                        OrgLink(org: org)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(category)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// The category tiles as their own page, for the button on the Student Leadership office page.
struct OrgsBrowsePage: View {
    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                OrgCategoryGrid()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
        .navigationTitle("Student orgs")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Org cards

/// An org's card that opens its page.
struct OrgLink: View {
    let org: Org
    var query: String = ""

    var body: some View {
        NavigationLink {
            OrgDetailView(org: org)
        } label: {
            OrgRow(org: org, query: query)
        }
        .buttonStyle(.plain)
    }
}

struct OrgRow: View {
    let org: Org
    var query: String = ""

    var body: some View {
        HStack(spacing: 14) {
            OrgLogo(org: org, size: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(org.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(org.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if matchedDescriptionOnly {
                    Text("Matches description")
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

    /// True when the search words aren't in the name or category, so the match came from the description.
    private var matchedDescriptionOnly: Bool {
        let words = DirectoryData.searchWords(query)
        guard !words.isEmpty else { return false }
        let visible = [org.name, org.shortName ?? "", org.category].joined(separator: " ").lowercased()
        return !words.allSatisfy { visible.contains($0) }
    }
}

/// The org's logo, or two letters on a purple tile if it doesn't have one.
struct OrgLogo: View {
    let org: Org
    var size: CGFloat = 46

    var body: some View {
        if let image = OrgLogos.image(for: org.slug) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.34, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: size * 0.34, style: .continuous).stroke(Color.black.opacity(0.08), lineWidth: 0.5))
        } else {
            Text(org.badge)
                .font(.system(size: size * 0.37, weight: .black, design: .rounded))
                .foregroundStyle(lociAccent)
                .frame(width: size, height: size)
                .background(lociAccent.opacity(0.2), in: RoundedRectangle(cornerRadius: size * 0.34, style: .continuous))
        }
    }
}

// MARK: - Org page

/// The page that slides in after tapping an org.
struct OrgDetailView: View {
    let org: Org

    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header

                    Text(org.description)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if linkItems.isEmpty {
                        Text("No email or social links listed.")
                            .font(.caption)
                            .foregroundStyle(lociAccent.opacity(0.8))
                    } else {
                        InfoCard(items: linkItems)
                    }

                    if let url = org.involvementLinkURL {
                        Link(destination: url) {
                            Label("Open on Involvement Link", systemImage: "arrow.up.right.square")
                        }
                        .buttonStyle(ModernButtonStyle())
                    }

                    Text("Source: Involvement Link, collected October 2026.")
                        .font(.caption)
                        .foregroundStyle(lociAccent.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Organization")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        VStack(spacing: 10) {
            OrgLogo(org: org, size: 76)
            Text(org.subtitle.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(lociAccent.opacity(0.8))
                .multilineTextAlignment(.center)
            Text(org.name)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(lociAccent)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    /// Email, website, chat and social links, whichever the org has.
    private var linkItems: [InfoItem] {
        var items: [InfoItem] = []
        if let value = org.email {
            items.append(InfoItem(icon: "envelope", label: "Email", value: value, url: URL(string: "mailto:" + value)))
        }
        if let value = org.website {
            var label = "Website"
            if org.websiteLabel == "National site" { label = "Website (national org)" }
            if org.websiteLabel == "Shop" { label = "Online shop" }
            items.append(InfoItem(icon: "globe", label: label, value: DirectoryData.shortWebAddress(value), url: URL(string: value)))
        }
        if let value = org.chat {
            let label = value.lowercased().contains("groupme") ? "GroupMe" : "Discord"
            items.append(InfoItem(icon: "bubble.left.and.bubble.right", label: label, value: DirectoryData.shortWebAddress(value), url: URL(string: value)))
        }
        if let value = org.instagram {
            items.append(InfoItem(icon: "camera", label: "Instagram", value: DirectoryData.shortWebAddress(value), url: URL(string: value)))
        }
        if let value = org.facebook {
            items.append(InfoItem(icon: "person.2", label: "Facebook", value: DirectoryData.shortWebAddress(value), url: URL(string: value)))
        }
        for link in org.otherLinks ?? [] where link.count == 2 {
            items.append(InfoItem(icon: "link", label: link[0], value: DirectoryData.shortWebAddress(link[1]), url: URL(string: link[1])))
        }
        return items
    }
}

/// A white box of info rows with lines between them.
struct InfoCard: View {
    let items: [InfoItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 52)
                }
                InfoRow(item: item)
            }
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Logos

/// Org logos from logos.json (small WebP images), decoded the first time each one is shown.
enum OrgLogos {
    /// slug → "data:image/webp;base64,…"
    private static let encoded: [String: String] = {
        guard let url = Bundle.main.url(forResource: "logos", withExtension: "json") else {
            print("Directory: logos.json is missing from the app bundle")
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Directory: couldn't read logos.json: \(error)")
            return [:]
        }
    }()

    private static var decoded: [String: Image] = [:]

    static func has(_ slug: String) -> Bool {
        encoded[slug] != nil
    }

    static func image(for slug: String) -> Image? {
        if let image = decoded[slug] { return image }
        guard let text = encoded[slug],
              let comma = text.firstIndex(of: ","),
              let data = Data(base64Encoded: String(text[text.index(after: comma)...]))
        else { return nil }

        #if canImport(UIKit)
        guard let picture = UIImage(data: data) else { return nil }
        let image = Image(uiImage: picture)
        #else
        guard let picture = NSImage(data: data) else { return nil }
        let image = Image(nsImage: picture)
        #endif

        decoded[slug] = image
        return image
    }
}
