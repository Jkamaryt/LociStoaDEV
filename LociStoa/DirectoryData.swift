import Foundation

// MARK: - Data for the Directory
// Offices, people and orgs are loaded from offices.json, people.json and orgs.json,
// which ship inside the app. Org logos are in logos.json (see OrgLogos in OrgsTab.swift).
// When the team picks a database (SCRUM-43), only this file needs to change.
// `nonisolated` lets these types be used anywhere. This project runs code
// on the main actor by default, and plain data doesn't need that.

nonisolated struct Office: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let goHereFor: String
    var subtitle: String?
    var keywords: [String]?
    var location: String?
    var mapSearch: String?
    var hours: String?
    var phone: String?
    var phone2: LabeledPhone?
    var text: String?
    var email: String?
    var website: String?
    var note: String?
    var showOrgsButton: Bool?
    var departments: [String]?

    var pinKey: String { "office:" + id }

    /// Everything the search box looks through, in lowercase.
    var searchText: String {
        let parts: [String?] = [name, subtitle, category, goHereFor, keywords?.joined(separator: " "), location, email]
        return parts.compactMap { $0 }.joined(separator: " ").lowercased()
    }
}

nonisolated struct LabeledPhone: Codable, Hashable {
    let label: String
    let number: String
}

/// One faculty or staff member, from people.json (MTU employee listing, Sept. 14, 2026).
/// There are no phone numbers on purpose.
nonisolated struct Person: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    var degree: String?
    let email: String
    let faculty: Bool
    let title: String
    let department: String
    /// The department name exactly as the listing spells it. Used to link people to offices.
    let departmentRaw: String
    var office: String?
    var mapSearch: String?

    var role: String { faculty ? "Faculty" : "Staff" }

    var pinKey: String { "person:" + id }

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    /// "Jane Q. Smith" becomes "JS".
    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? (parts.last?.first.map(String.init) ?? "") : ""
        return (first + last).uppercased()
    }

    /// "Professor · Chemistry"
    var subtitle: String {
        [title, department].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    var searchText: String {
        let parts: [String?] = [name, title, department, departmentRaw, office, email, role]
        return parts.compactMap { $0 }.joined(separator: " ").lowercased()
    }
}

/// A department on the People tab, with how many people are in it.
nonisolated struct Department: Identifiable, Hashable {
    /// The listing's spelling, e.g. "Registrar's Office".
    let raw: String
    /// The cleaned-up name shown on screen.
    let name: String
    let count: Int

    var id: String { raw }
}

/// One student organization, from orgs.json (Involvement Link, collected October 2026).
nonisolated struct Org: Codable, Identifiable, Hashable {
    let category: String
    let name: String
    var shortName: String?
    let description: String
    /// The org's ID on Involvement Link. Also the key for its logo in logos.json.
    let slug: String
    var email: String?
    var website: String?
    /// "National site" or "Shop" when the website isn't the club's own page.
    var websiteLabel: String?
    var chat: String?
    var instagram: String?
    var facebook: String?
    /// Extra links as [label, address] pairs, e.g. ["X", "https://twitter.com/..."].
    var otherLinks: [[String]]?

    var id: String { slug }

    var pinKey: String { "org:" + slug }

    /// Show the short name only when it's different from the full name.
    var visibleShortName: String? {
        guard let shortName, shortName.lowercased() != name.lowercased() else { return nil }
        return shortName
    }

    /// "Club Sports · AST"
    var subtitle: String {
        [category, visibleShortName].compactMap { $0 }.joined(separator: " · ")
    }

    /// Two letters for orgs without a logo, e.g. "Chess Club" becomes "CH".
    var badge: String {
        let skip: Set<String> = ["the", "of", "at", "and", "for", "a", "michigan", "tech", "technological", "university", "mtu", "club"]
        let words = name
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { !skip.contains($0.lowercased()) }
        let letters = words.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return (letters.isEmpty ? String(name.prefix(2)) : letters).uppercased()
    }

    var involvementLinkURL: URL? {
        URL(string: "https://www.involvement.mtu.edu/organization/" + slug)
    }

    var searchText: String {
        [name, shortName ?? "", category, description].joined(separator: " ").lowercased()
    }
}

/// Departments that start with the same letter, for the A–Z list.
nonisolated struct DepartmentGroup: Identifiable {
    let letter: String
    let departments: [Department]

    var id: String { letter }
}

/// One card in the sliding emergency row.
nonisolated struct EmergencyNumber: Identifiable {
    let name: String
    let number: String
    let detail: String
    var isPrimary = false

    var id: String { name }
    var dialURL: URL? { DirectoryData.phoneURL(number) }
}

nonisolated enum DirectoryData {

    // MARK: Offices

    static let offices: [Office] = load("offices")

    static let officeByID: [String: Office] =
        Dictionary(offices.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    /// Filter chips and section headings on the Offices tab, in this order.
    static let officeCategories = ["Academic", "Administrative", "Student Services", "Health", "IT", "Campus Safety"]

    /// SF Symbol for each office category.
    static func icon(for category: String) -> String {
        switch category {
        case "Academic": return "graduationcap.fill"
        case "Administrative": return "doc.text.fill"
        case "Student Services": return "heart.fill"
        case "Health": return "cross.case.fill"
        case "IT": return "laptopcomputer"
        case "Campus Safety": return "checkmark.shield.fill"
        default: return "building.2.fill"
        }
    }

    // MARK: People and departments

    static let people: [Person] = load("people")

    static let personByID: [String: Person] =
        Dictionary(people.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    /// Every department, A to Z.
    static let departments: [Department] = {
        var found: [String: (name: String, count: Int)] = [:]
        for person in people {
            found[person.departmentRaw, default: (name: person.department, count: 0)].count += 1
        }
        return found
            .map { Department(raw: $0.key, name: $0.value.name, count: $0.value.count) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }()

    /// The A–Z list on the People tab: "A" with its departments, then "B", and so on.
    static let departmentGroups: [DepartmentGroup] = {
        let byLetter = Dictionary(grouping: departments) { String($0.name.prefix(1)).uppercased() }
        return byLetter.keys.sorted().map { DepartmentGroup(letter: $0, departments: byLetter[$0] ?? []) }
    }()

    static let departmentByRaw: [String: Department] =
        Dictionary(uniqueKeysWithValues: departments.map { ($0.raw, $0) })

    static let peopleByDepartment: [String: [Person]] =
        Dictionary(grouping: people) { $0.departmentRaw }

    /// Links a department to its office, e.g. "Registrar's Office" to the Registrar's office page.
    static let officeForDepartment: [String: Office] = {
        var links: [String: Office] = [:]
        for office in offices {
            for department in office.departments ?? [] {
                links[department] = office
            }
        }
        return links
    }()

    // MARK: Student orgs

    static let orgs: [Org] = load("orgs")

    static let orgBySlug: [String: Org] =
        Dictionary(orgs.map { ($0.slug, $0) }, uniquingKeysWith: { first, _ in first })

    /// Category tiles on the Orgs tab, in this order (biggest first).
    static let orgCategories = ["Club Sports", "Academic/Professional", "Special Interest", "Service", "Greek Life", "Religious", "Cultural"]

    static let orgsByCategory: [String: [Org]] =
        Dictionary(grouping: orgs) { $0.category }

    // MARK: Emergency numbers
    // Sources: mtu.edu/well-being/emergency, 988lifeline.org,
    // poisonhelp.hrsa.gov and mi211.org (checked November 2026).

    static let emergencyNumbers: [EmergencyNumber] = [
        EmergencyNumber(name: "Emergency", number: "911", detail: "Police, fire and ambulance", isPrimary: true),
        EmergencyNumber(name: "Campus Police", number: "906-487-2216", detail: "Public Safety, answered 24/7"),
        EmergencyNumber(name: "Crisis Lifeline", number: "988", detail: "Call or text, 24/7"),
        EmergencyNumber(name: "Mantra Health", number: "877-316-4002", detail: "Talk to a mental health professional"),
        EmergencyNumber(name: "Portage ER", number: "906-483-1000", detail: "Hospital, 500 Campus Dr, Hancock"),
        EmergencyNumber(name: "Poison Help", number: "800-222-1222", detail: "Free and confidential, 24/7"),
        EmergencyNumber(name: "Shelter Home", number: "906-337-5623", detail: "Help with domestic violence"),
        EmergencyNumber(name: "Michigan 211", number: "211", detail: "Food, housing and other local help"),
    ]

    // MARK: Helpers

    /// "906-487-2216" becomes tel:9064872216
    static func phoneURL(_ number: String) -> URL? {
        URL(string: "tel:" + number.filter(\.isNumber))
    }

    static func textURL(_ number: String) -> URL? {
        URL(string: "sms:" + number.filter(\.isNumber))
    }

    /// Opens Apple Maps searching for the place.
    static func mapsURL(_ place: String) -> URL? {
        var parts = URLComponents(string: "https://maps.apple.com/")
        parts?.queryItems = [URLQueryItem(name: "q", value: place)]
        return parts?.url
    }

    /// "https://www.mtu.edu/registrar/" becomes "mtu.edu/registrar"
    static func shortWebAddress(_ address: String) -> String {
        var text = address
        for prefix in ["https://", "http://", "www."] where text.hasPrefix(prefix) {
            text.removeFirst(prefix.count)
        }
        if text.hasSuffix("/") { text.removeLast() }
        return text
    }

    /// Splits a search into lowercase words.
    static func searchWords(_ query: String) -> [String] {
        query.lowercased().split(separator: " ").map(String.init)
    }

    private static func load<T: Decodable>(_ file: String) -> [T] {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            print("Directory: \(file).json is missing from the app bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Directory: couldn't read \(file).json: \(error)")
            return []
        }
    }
}
