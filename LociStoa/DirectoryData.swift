import Foundation

// MARK: - Data for the Directory
// The office list is loaded from offices.json, which ships inside the app.
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
