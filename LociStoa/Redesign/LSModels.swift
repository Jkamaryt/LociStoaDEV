import Foundation

// LociStoa redesign: the data.
//
// How the redesign fits together (all files start with "LS"):
//   CampusData/*.csv     the content (people, offices, orgs, ...). Edit these to change what the app shows.
//   LSModels.swift       THIS FILE: reads the CSV files and turns each row into a Swift struct.
//   LSStore.swift        keeps track of what the student is doing (state) and works out what screens show.
//   LSTheme.swift        colors and the small reusable pieces (cards, chips, search field).
//   LS...Screen.swift    what each screen looks like.

// MARK: - CSV reader

enum LSCSV {
    /// Reads CSV text into rows. Each row is a dictionary keyed by the column names in the first line.
    /// Handles quoted cells, plus commas and line breaks inside quotes.
    static func parse(_ text: String) -> [[String: String]] {
        var scalars = Array(text.unicodeScalars)
        if let first = scalars.first, first.value == 0xFEFF {   // marker Excel adds at the start
            scalars.removeFirst()
        }
        let quote: Unicode.Scalar = "\""
        let comma: Unicode.Scalar = ","
        let newline: Unicode.Scalar = "\n"
        let carriage: Unicode.Scalar = "\r"

        var rows: [[String]] = []
        var row: [String] = []
        var cell = ""
        var quoted = false
        var i = 0
        let n = scalars.count
        while i < n {
            let ch = scalars[i]
            if quoted {
                if ch == quote && i + 1 < n && scalars[i + 1] == quote {
                    cell.unicodeScalars.append(quote)
                    i += 1
                } else if ch == quote {
                    quoted = false
                } else {
                    cell.unicodeScalars.append(ch)
                }
            } else if ch == quote {
                quoted = true
            } else if ch == comma {
                row.append(cell)
                cell = ""
            } else if ch == newline || ch == carriage {
                if ch == carriage && i + 1 < n && scalars[i + 1] == newline {
                    i += 1
                }
                row.append(cell)
                cell = ""
                if row.count > 1 || row[0] != "" {
                    rows.append(row)
                }
                row = []
            } else {
                cell.unicodeScalars.append(ch)
            }
            i += 1
        }
        if cell != "" || !row.isEmpty {
            row.append(cell)
            rows.append(row)
        }
        guard !rows.isEmpty else { return [] }

        let header = rows.removeFirst().map { $0.trimmingCharacters(in: .whitespaces) }
        var result: [[String: String]] = []
        for r in rows {
            var item: [String: String] = [:]
            for (index, name) in header.enumerated() {
                item[name] = index < r.count ? r[index] : ""
            }
            result.append(item)
        }
        return result
    }

    /// Finds a file that was bundled with the app, wherever Xcode put it.
    static func bundleURL(_ name: String, _ ext: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }
        return Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "CampusData")
    }

    /// Loads one CSV table from the app bundle, e.g. table("people") reads people.csv.
    static func table(_ name: String) -> [[String: String]] {
        guard let url = bundleURL(name, "csv"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return parse(text)
    }
}

// MARK: - One struct per CSV table

struct LSPerson: Identifiable, Hashable {
    let id: Int
    let name: String
    let role: String
    let dept: String
    let office: String
    let email: String
    let level: Int          // lower number = higher up in the department
    let isFaculty: Bool
    let initials: String
    let hay: String         // lowercase text that search looks through
}

struct LSDept: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let count: Int
    let hay: String
}

struct LSOffice: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let goHereFor: String
    let location: String
    let hours: String
    let phone: String
    let email: String
    let website: String
    let note: String
    let departments: [String]
    let hay: String
}

struct LSOrg: Identifiable, Hashable {
    let id: Int             // position in the list
    let logoIndex: Int      // position in the logo sheet, -1 if it has no logo
    let category: String
    let name: String
    let shortName: String
    let desc: String
    let email: String
    let site: String
    let hay: String
}

struct LSCenter: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let subjects: String
    let building: String
    let room: String
    let hours: String
    let how: String
    let contact: String
    let email: String
    let phone: String
    let book: String
    let term: String
    let website: String
    let notes: String
    let codes: [String]     // subject codes this center helps with, e.g. ["MA"]
    let mapBuilding: String
    let hay: String
}

struct LSBuilding: Identifiable, Hashable {
    let id: String
    let short: String
    let name: String
    let layer: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let inside: String
}

struct LSLingo: Identifiable, Hashable {
    var id: String { term }
    let term: String
    let meaning: String
    let buildingID: String
}

struct LSNumber: Identifiable, Hashable {
    let id: Int
    let number: String
    let chip: String
    let label: String
    let primary: Bool
}

struct LSLink: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let url: String
}

struct LSSubject: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
}

/// One row of schools.csv: which email domain belongs to which school, and which colors it gets.
struct LSSchool: Identifiable, Hashable {
    let id: String
    let name: String
    let short: String
    let domain: String      // "mtu.edu"
    let provider: String    // "google" or "microsoft"
    let theme: String       // a palette name in LSTheme.swift
}

struct LSLogoIndex: Decodable {
    let columns: Int
    let cell: Int
    let order: [String]
}

// MARK: - What the student saves on this phone

struct LSClass: Identifiable, Codable, Hashable {
    var id = UUID()
    var subj: String        // "MIS"
    var num: String         // "4000"
    var days: String        // letters from MTWRF, e.g. "MWF"
    var start: String       // "10:00" (24-hour)
    var end: String         // "10:50"
    var loc: String         // "Fisher 135" or ""
}

struct LSTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var type: String
    var course: String
    var due: String
    var done: Bool
}

/// Who is signed in: their email and which school it belongs to.
struct LSUser: Codable, Hashable {
    var email: String
    var school: String      // school_id from schools.csv
}

struct LSSaved: Codable {
    var classes: [LSClass] = []
    var tasks: [LSTask] = []
    var favs: [String] = []
    var user: LSUser?       // nil = signed out
    var dark: Bool?         // nil = follow the phone's setting
    var widgets: [String: Bool] = [:]
}

// MARK: - All the campus data, loaded once

final class LSCampusData {
    let people: [LSPerson]
    let depts: [LSDept]
    let deptMeta: [String: (category: String, reportsTo: String)]
    let offices: [LSOffice]
    let orgs: [LSOrg]
    let orgCategories: [String]
    let centers: [LSCenter]
    let subjects: [LSSubject]
    let buildings: [LSBuilding]
    let lingo: [LSLingo]
    let numbers: [LSNumber]
    let links: [LSLink]
    let schools: [LSSchool]
    let logoColumns: Int
    let logoCell: Int

    init() {
        // "a; b; c" -> ["a", "b", "c"]
        func list(_ text: String?) -> [String] {
            guard let text = text, !text.isEmpty else { return [] }
            return text.split(separator: ";")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        func s(_ row: [String: String], _ key: String) -> String { row[key] ?? "" }

        // departments.csv
        var meta: [String: (category: String, reportsTo: String)] = [:]
        for d in LSCSV.table("departments") {
            meta[s(d, "name")] = (s(d, "category"), s(d, "reports_to"))
        }
        deptMeta = meta

        // subjects.csv
        subjects = LSCSV.table("subjects").map { LSSubject(code: s($0, "code"), name: s($0, "name")) }

        // people.csv
        var loadedPeople: [LSPerson] = []
        for (index, p) in LSCSV.table("people").enumerated() {
            let name = s(p, "name")
            let title = s(p, "title")
            let dept = s(p, "department")
            let office = s(p, "office")
            loadedPeople.append(LSPerson(
                id: index,
                name: name,
                role: title,
                dept: dept,
                office: office.isEmpty ? "Not listed" : office,
                email: s(p, "email"),
                level: Int(s(p, "rank_level")) ?? 99,
                isFaculty: s(p, "is_faculty") == "1",
                initials: LSCampusData.initials(name),
                hay: (name + " " + title + " " + dept).lowercased()
            ))
        }
        people = loadedPeople

        var counts: [String: Int] = [:]
        for p in loadedPeople {
            counts[p.dept, default: 0] += 1
        }
        depts = counts.keys.sorted().map { LSDept(name: $0, count: counts[$0] ?? 0, hay: $0.lowercased()) }

        // offices.csv
        offices = LSCSV.table("offices").map { f in
            let keywords = list(f["keywords"])
            let name = s(f, "name")
            let goHereFor = s(f, "go_here_for")
            let category = s(f, "category")
            return LSOffice(
                id: s(f, "office_id"),
                name: name,
                category: category,
                goHereFor: goHereFor,
                location: s(f, "location"),
                hours: s(f, "hours"),
                phone: s(f, "phone"),
                email: s(f, "email"),
                website: s(f, "website"),
                note: s(f, "note"),
                departments: list(f["departments"]),
                hay: (name + " " + goHereFor + " " + keywords.joined(separator: " ") + " " + category).lowercased()
            )
        }

        // org-logos.json: which logo sits where in the big logo image
        var logoOrder: [String] = []
        var columns = 17
        var cell = 96
        if let url = LSCSV.bundleURL("org-logos", "json"),
           let raw = try? Data(contentsOf: url),
           let index = try? JSONDecoder().decode(LSLogoIndex.self, from: raw) {
            logoOrder = index.order
            columns = index.columns
            cell = index.cell
        }
        logoColumns = columns
        logoCell = cell

        // student_orgs.csv
        var loadedOrgs: [LSOrg] = []
        var categories: [String] = []
        for (index, o) in LSCSV.table("student_orgs").enumerated() {
            let name = s(o, "name")
            let shortName = s(o, "short_name")
            let category = s(o, "category")
            let desc = s(o, "description")
            loadedOrgs.append(LSOrg(
                id: index,
                logoIndex: logoOrder.firstIndex(of: s(o, "org_id")) ?? -1,
                category: category,
                name: name,
                shortName: shortName,
                desc: desc.isEmpty ? "No description listed." : desc,
                email: s(o, "email"),
                site: s(o, "website"),
                hay: (name + " " + shortName + " " + category).lowercased()
            ))
            if !categories.contains(category) {
                categories.append(category)
            }
        }
        orgs = loadedOrgs
        orgCategories = categories.sorted()

        // learning_centers.csv
        centers = LSCSV.table("learning_centers").map { c in
            let codes = list(c["subject_codes"])
            let name = s(c, "name")
            let subjectsCovered = s(c, "subjects_covered")
            let building = s(c, "building")
            return LSCenter(
                id: s(c, "center_id"),
                name: name,
                category: s(c, "category"),
                subjects: subjectsCovered,
                building: building,
                room: s(c, "room"),
                hours: s(c, "hours"),
                how: s(c, "how_to_get_help"),
                contact: s(c, "contact"),
                email: s(c, "email"),
                phone: s(c, "phone"),
                book: s(c, "booking_url"),
                term: s(c, "term"),
                website: s(c, "website"),
                notes: s(c, "notes"),
                codes: codes,
                mapBuilding: s(c, "map_building_id"),
                hay: (name + " " + subjectsCovered + " " + building + " " + codes.joined(separator: " ") + " tutor tutoring").lowercased()
            )
        }

        // buildings.csv, campus_lingo.csv, emergency_numbers.csv, quick_links.csv
        buildings = LSCSV.table("buildings").map { b in
            LSBuilding(
                id: s(b, "building_id"),
                short: s(b, "short_name"),
                name: s(b, "name"),
                layer: s(b, "category"),
                x: Double(s(b, "map_x")) ?? 0,
                y: Double(s(b, "map_y")) ?? 0,
                w: Double(s(b, "map_width")) ?? 60,
                h: Double(s(b, "map_height")) ?? 40,
                inside: s(b, "whats_inside")
            )
        }
        lingo = LSCSV.table("campus_lingo").map {
            LSLingo(term: s($0, "term"), meaning: s($0, "meaning"), buildingID: s($0, "building_id"))
        }
        var loadedNumbers: [LSNumber] = []
        for (index, row) in LSCSV.table("emergency_numbers").enumerated() {
            loadedNumbers.append(LSNumber(
                id: index,
                number: s(row, "number"),
                chip: s(row, "short_label"),
                label: s(row, "description"),
                primary: s(row, "is_primary") == "1"
            ))
        }
        numbers = loadedNumbers
        links = LSCSV.table("quick_links").map { LSLink(label: s($0, "label"), url: s($0, "url")) }

        // schools.csv (falls back to Michigan Tech alone if the file is missing)
        var loadedSchools = LSCSV.table("schools").map { row in
            LSSchool(
                id: s(row, "school_id"),
                name: s(row, "name"),
                short: s(row, "short_name"),
                domain: s(row, "email_domain").lowercased(),
                provider: s(row, "sign_in_provider"),
                theme: s(row, "theme")
            )
        }
        if loadedSchools.isEmpty {
            loadedSchools = [LSSchool(id: "mtu", name: "Michigan Technological University", short: "Michigan Tech",
                                      domain: "mtu.edu", provider: "google", theme: "mtu")]
        }
        schools = loadedSchools
    }

    /// "Hannah W. Abbotts" -> "HA"
    static func initials(_ name: String) -> String {
        var cleaned = ""
        for scalar in name.unicodeScalars {
            let v = scalar.value
            let isLetter = (v >= 65 && v <= 90) || (v >= 97 && v <= 122)
            if isLetter || scalar == " " || scalar == "." || scalar == "'" || scalar == "-" {
                cleaned.unicodeScalars.append(scalar)
            }
        }
        let parts = cleaned.split(separator: " ")
        var result = "?"
        if let first = parts.first, let letter = first.first {
            result = String(letter)
        }
        if parts.count > 1, let last = parts.last, let letter = last.first {
            result += String(letter)
        }
        return result.uppercased()
    }

    var summary: String {
        "\(people.count) people · \(depts.count) departments · \(offices.count) offices · \(orgs.count) student orgs · \(centers.count) learning centers"
    }
}
