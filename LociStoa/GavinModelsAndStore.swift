import SwiftUI
import Combine

// MARK: - Original LociStoa Dashboard Sheet Enum
enum DashboardSheet: String, Identifiable {
    case map, links, schedule, contacts, planner, careerFair, chatbot, nomenclature
    var id: String { self.rawValue }
}

// MARK: - Navigation & Sheet Enums
enum GavinTab: String, CaseIterable, Identifiable {
    case home = "home"
    case people = "people"
    case map = "map"
    case planner = "planner"
    case more = "more"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .people: return "People"
        case .map: return "Map"
        case .planner: return "Planner"
        case .more: return "More"
        }
    }
    
    var iconKind: LociIconKind {
        switch self {
        case .home: return .home
        case .people: return .people
        case .map: return .map
        case .planner: return .planner
        case .more: return .more
        }
    }
}

enum GavinPeopleSubView: String, CaseIterable, Identifiable {
    case dir = "dir"
    case help = "help"
    case depts = "depts"
    case orgs = "orgs"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .dir: return "Directory"
        case .help: return "Get help"
        case .depts: return "Departments"
        case .orgs: return "Student orgs"
        }
    }
}

enum GavinPlanMode: String, CaseIterable, Identifiable {
    case tasks = "tasks"
    case times = "times"
    case periods = "periods"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .tasks: return "Tasks"
        case .times: return "My classes"
        case .periods: return "Periods"
        }
    }
}

enum GavinMapViewMode: String, CaseIterable, Identifiable {
    case interactive = "interactive"
    case diagram = "diagram"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .interactive: return "Live Interactive Map"
        case .diagram: return "Campus Diagram"
        }
    }
}

enum GavinActiveSheet: String, Identifiable {
    case emergency = "emergency"
    case contact = "contact"
    case add = "add"
    case classSheet = "class"
    case search = "search"
    
    var id: String { rawValue }
}

// MARK: - Data Models (Matching Main.dc.html + Original LociStoa Models)
struct GavinPerson: Identifiable, Hashable {
    let id: Int
    let name: String
    let role: String
    let dept: String
    let office: String
    let email: String
    let phone: String
    let level: Int
    let fac: Bool
    let initials: String
    let hay: String
}

struct GavinDepartment: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let n: Int
    let hay: String
    
    var countText: String {
        "\(n) \(n == 1 ? "person" : "people")"
    }
}

struct GavinOffice: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let goHereFor: String
    let keywords: [String]?
    let location: String?
    let hours: String?
    let phone: String?
    let email: String?
    let website: String?
    let note: String?
    let departments: [String]?
    
    var hay: String {
        let kw = (keywords ?? []).joined(separator: " ")
        return "\(name) \(goHereFor) \(kw) \(category)".lowercased()
    }
}

struct GavinOrg: Identifiable, Hashable {
    let i: Int
    var id: Int { i }
    let cat: String
    let name: String
    let short: String
    let desc: String
    let email: String
    let site: String
    let hay: String
}

struct GavinSubject: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
}

struct GavinClassItem: Identifiable, Codable, Hashable {
    let id: Int
    let subj: String
    let num: String
    let days: String
    let start: String
    let end: String
    let loc: String
}

struct GavinTaskItem: Identifiable, Codable, Hashable {
    let id: Int
    let type: String
    let course: String
    var description: String = ""
    var dueDate: Date? = nil
    let due: String
    var done: Bool
    var toDoItemId: UUID? = nil
}

struct GavinMapBuilding: Identifiable, Hashable {
    let id: String
    let short: String
    let name: String
    let layer: String
    let x: CGFloat
    let y: CGFloat
    let w: CGFloat
    let h: CGFloat
    let inside: String
    
    var left: CGFloat { x - w / 2.0 }
    var top: CGFloat { y - h / 2.0 }
    
    var bgColor: Color {
        Self.layerColor(for: layer)
    }
    
    static func layerColor(for layer: String) -> Color {
        switch layer {
        case "Academic": return Color(hex: 0x1F4E79)
        case "Services": return Color(hex: 0x9C2F5B)
        case "Housing":  return Color(hex: 0x8A5A00)
        case "Athletics": return Color(hex: 0x2E6B3F)
        default:         return Color(hex: 0x8C939B)
        }
    }
}

struct GavinEmergencyNumber: Identifiable {
    let id: Int
    let number: String
    let chip: String
    let label: String
    let primary: Bool
}

struct GavinLingoItem: Identifiable {
    var id: String { term }
    let term: String
    let meaning: String
    let buildingId: String
    var details: String = ""
}

struct GavinToolShortcut: Identifiable {
    var id: String { label }
    let label: String
    let sub: String
    let icon: LociIconKind
    let kw: String
    let action: () -> Void
}

// MARK: - Persisted State Container (locistoa-proto-v3)
private struct GavinSavedState: Codable {
    var theme: String?
    var widgets: [String: Bool]?
    var favs: [String: Bool]?
    var classes: [GavinClassItem]?
    var tasks: [GavinTaskItem]?
}

// MARK: - Raw JSON Bundle Container
private struct GavinRawBundle: Decodable {
    let P: [[GavinJSONValue]]
    let DM: [String: [String]]
    let O: [[String]]
    let F: [GavinOffice]
    let S: [[String]]
}

private enum GavinJSONValue: Decodable {
    case string(String)
    case int(Int)
    
    var stringValue: String {
        if case .string(let s) = self { return s }
        if case .int(let i) = self { return String(i) }
        return ""
    }
    
    var intValue: Int {
        if case .int(let i) = self { return i }
        if case .string(let s) = self { return Int(s) ?? 0 }
        return 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else {
            self = .string("")
        }
    }
}

// MARK: - Main Store (Exact replication of Main.dc.html + All Original LociStoa Features)
@MainActor
final class LociStoaStore: ObservableObject {
    // Static Datasets loaded from GavinPrototypeData.json
    let people: [GavinPerson]
    let depts: [GavinDepartment]
    let deptMeta: [String: [String]]
    let offices: [GavinOffice]
    let orgs: [GavinOrg]
    let orgCatNames: [String]
    let subjects: [GavinSubject]
    
    // Original LociStoa ViewModels & State
    @Published var isLoggedIn: Bool = false
    @Published var showingAdminSettings: Bool = false
    @Published var activeDashboardSheet: DashboardSheet? = nil
    @Published var focusedMapContact: Contact? = nil
    @Published var customPrimaryBgColor: Color? = nil
    @Published var customSecondaryAccentColor: Color? = nil
    @Published var fridayScheduleEnabled: Bool = false
    
    let toDoList = ToDoList()
    let directoryVM = DirectoryViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var isSyncingTasks = false
    
    // Persisted State
    @Published var theme: LociTheme = .purple { didSet { persistState() } }
    @Published var widgets: [String: Bool] = [:] { didSet { persistState() } }
    @Published var favs: [String: Bool] = [:] { didSet { persistState() } }
    @Published var classes: [GavinClassItem] = [] { didSet { persistState() } }
    @Published var tasks: [GavinTaskItem] = [] { didSet { persistState() } }
    
    // Navigation & View State
    @Published var tab: GavinTab = .home
    @Published var calDay: Int? = nil
    @Published var pv: GavinPeopleSubView = .dir
    @Published var planMode: GavinPlanMode = .tasks
    @Published var mapMode: GavinMapViewMode = .interactive
    
    // People / Directory / Depts / Help / Orgs State
    @Published var dirQuery: String = ""
    @Published var filter: String = "All"
    @Published var dirLoading: Bool = false
    @Published var dept: String? = nil
    @Published var deptQuery: String = ""
    @Published var office: String? = nil
    @Published var helpQuery: String = ""
    @Published var org: Int? = nil
    @Published var orgQuery: String = ""
    @Published var orgCat: String = "All"
    
    // Sheets, Modals & Toasts
    @Published var sheet: GavinActiveSheet? = nil
    @Published var contactId: Int? = nil
    @Published var query: String = ""
    @Published var toast: (text: String, id: Int)? = nil
    @Published var confirm: Int? = nil
    
    // Map State
    @Published var layer: String = "All"
    @Published var building: String? = nil
    @Published var floor: String = "1F"
    @Published var showInteractiveIndoorSheet: Bool = false
    
    // Add Task Form State (supports both Gavin chips + original ToDoItem description & DatePicker)
    @Published var addType: String = "Assignment"
    @Published var addCourse: String? = nil
    @Published var addDescription: String = ""
    @Published var addDueDate: Date = Date()
    @Published var addHasDueDate: Bool = true
    
    // Add Class Form State
    @Published var cSubj: String? = nil
    @Published var cSubjQuery: String = ""
    @Published var cNum: String = ""
    @Published var cDays: [String: Bool] = [:]
    @Published var cStart: String = "10:00"
    @Published var cEnd: String = "10:50"
    @Published var cLoc: String = ""
    @Published var cErr: String = ""
    
    private var loadTask: Task<Void, Never>? = nil
    private var toastTask: Task<Void, Never>? = nil
    private let storageKey = "locistoa-proto-v3"
    private let capLimit = 40
    
    // Regular & Friday Period Times from original ScheduleView.swift
    static let regularPeriodTimes = [
        "08:30 - 09:18",
        "09:22 - 10:08",
        "10:13 - 11:07",
        "11:12 - 11:58",
        "12:03 - 12:49",
        "12:54 - 01:40",
        "01:45 - 02:31",
        "02:36 - 03:22"
    ]
    static let fridayPeriodTimes = [
        "08:30 - 09:17",
        "09:22 - 10:08",
        "10:13 - 11:07",
        "11:12 - 11:58",
        "12:03 - 12:49",
        "12:54 - 01:40",
        "01:45 - 02:31",
        "02:36 - 03:22"
    ]
    
    static let widgetDefinitions: [(key: String, label: String, sub: String, defaultOn: Bool)] = [
        ("next", "Next class", "Your upcoming class", true),
        ("cal", "This week", "A calendar of your classes", true),
        ("due", "Due soon", "Tasks from your planner", true),
        ("tools", "Campus tools", "Live map, schedule, directory, career fair, chatbot, and nomenclature", true),
        ("links", "Quick links", "Canvas, Banweb, and more", true),
        ("help", "Get help shortcuts", "Common needs, one tap away", true),
        ("saved", "Saved people", "Contacts you starred", true),
        ("org", "Student org of the day", "Discover a new organization", false),
        ("places", "People & places", "Shortcuts to the directory and map", false)
    ]
    
    static let emergencyNumbers: [GavinEmergencyNumber] = [
        GavinEmergencyNumber(id: 0, number: "911", chip: "911", label: "Police, fire, medical", primary: true),
        GavinEmergencyNumber(id: 1, number: "906-487-2216", chip: "Public Safety", label: "Public Safety, answered 24/7", primary: false),
        GavinEmergencyNumber(id: 2, number: "988", chip: "988 Crisis Line", label: "Suicide & Crisis Lifeline", primary: false),
        GavinEmergencyNumber(id: 3, number: "906-487-2538", chip: "Counseling", label: "Student mental health and counseling", primary: false),
        GavinEmergencyNumber(id: 4, number: "906-487-3889", chip: "Hall duty phone", label: "Residence hall duty phone", primary: false),
        GavinEmergencyNumber(id: 5, number: "906-487-TIPS", chip: "Tip line", label: "Anonymous tip line", primary: false)
    ]
    
    static let mapBuildings: [GavinMapBuilding] = [
        GavinMapBuilding(id: "admin", short: "Admin", name: "Administration Building", layer: "Services", x: 205, y: 270, w: 64, h: 44, inside: "Registrar, Financial Aid, Dean of Students, Career Services, and more"),
        GavinMapBuilding(id: "aob", short: "Academic Office", name: "Academic Office Building", layer: "Academic", x: 272, y: 205, w: 70, h: 44, inside: "College of Business, Social Sciences"),
        GavinMapBuilding(id: "rotc", short: "ROTC", name: "ROTC Building", layer: "Academic", x: 338, y: 195, w: 52, h: 40, inside: "Air Force and Army ROTC"),
        GavinMapBuilding(id: "meem", short: "MEEM", name: "R. L. Smith Building (MEEM)", layer: "Academic", x: 383, y: 255, w: 60, h: 46, inside: "Mechanical & Aerospace Engineering"),
        GavinMapBuilding(id: "chem", short: "Chem Sci", name: "Chemical Sciences & Engineering Building", layer: "Academic", x: 452, y: 250, w: 60, h: 46, inside: "Chemical Engineering, Chemistry"),
        GavinMapBuilding(id: "hstem", short: "H-STEM", name: "H-STEM Engineering & Health Technologies Complex", layer: "Academic", x: 478, y: 301, w: 52, h: 38, inside: "Health, Human & Biological Systems; Biomedical Engineering; Kinesiology"),
        GavinMapBuilding(id: "glrc", short: "GLRC", name: "Great Lakes Research Center", layer: "Academic", x: 560, y: 150, w: 60, h: 38, inside: "Research center on the waterfront"),
        GavinMapBuilding(id: "dow", short: "Dow", name: "Dow Environmental Sciences & Engineering Building", layer: "Academic", x: 602, y: 228, w: 64, h: 44, inside: "Biological Sciences; Civil, Environmental & Geospatial Engineering; Geological & Mining Engineering"),
        GavinMapBuilding(id: "eerc", short: "EERC", name: "Electrical Energy Resources Center", layer: "Academic", x: 538, y: 289, w: 56, h: 42, inside: "Electrical & Computer Engineering; Manufacturing & Mechanical Engineering Technology"),
        GavinMapBuilding(id: "dillman", short: "Dillman", name: "Grover C. Dillman Hall", layer: "Academic", x: 625, y: 306, w: 60, h: 40, inside: "Engineering Fundamentals"),
        GavinMapBuilding(id: "mm", short: "M&M", name: "Minerals & Materials Engineering Building", layer: "Academic", x: 716, y: 328, w: 60, h: 44, inside: "Materials Science & Engineering; Psychology & Human Factors"),
        GavinMapBuilding(id: "mub", short: "MUB", name: "Memorial Union Building", layer: "Services", x: 382, y: 331, w: 70, h: 44, inside: "Welcome Center, Campus Store, dining"),
        GavinMapBuilding(id: "lib", short: "Library", name: "Van Pelt and Opie Library", layer: "Services", x: 473, y: 362, w: 64, h: 44, inside: "Study space, archives, Center for Teaching & Learning"),
        GavinMapBuilding(id: "rekhi", short: "Rekhi", name: "Kanwal & Ann Rekhi Hall", layer: "Academic", x: 545, y: 392, w: 60, h: 42, inside: "College of Computing, Applied Computing, Computer Science"),
        GavinMapBuilding(id: "fisher", short: "Fisher", name: "Fisher Hall", layer: "Academic", x: 615, y: 432, w: 60, h: 42, inside: "Physics, Mathematical Sciences"),
        GavinMapBuilding(id: "dhh", short: "DHH", name: "Douglass Houghton Hall", layer: "Housing", x: 792, y: 375, w: 70, h: 42, inside: "Residence hall"),
        GavinMapBuilding(id: "walker", short: "Walker", name: "Walker Arts & Humanities Center", layer: "Academic", x: 868, y: 462, w: 60, h: 40, inside: "College of Sciences & Arts, Humanities, Visual & Performing Arts"),
        GavinMapBuilding(id: "rozsa", short: "Rozsa", name: "Rozsa Center for the Performing Arts", layer: "Academic", x: 938, y: 420, w: 62, h: 40, inside: "Concerts, theatre, and events"),
        GavinMapBuilding(id: "east", short: "East Hall", name: "East Hall", layer: "Housing", x: 955, y: 512, w: 70, h: 34, inside: "Residence hall"),
        GavinMapBuilding(id: "wads", short: "Wadsworth", name: "Wadsworth Hall", layer: "Housing", x: 770, y: 577, w: 150, h: 40, inside: "Residence hall and dining"),
        GavinMapBuilding(id: "mcnair", short: "McNair", name: "West and East McNair Halls", layer: "Housing", x: 935, y: 618, w: 84, h: 40, inside: "Residence halls and dining"),
        GavinMapBuilding(id: "noblet", short: "Noblet", name: "U. J. Noblet Forestry Building", layer: "Academic", x: 515, y: 632, w: 70, h: 42, inside: "College of Forest Resources & Environmental Science"),
        GavinMapBuilding(id: "sdc", short: "SDC", name: "Student Development Complex", layer: "Athletics", x: 690, y: 668, w: 90, h: 44, inside: "Recreation, fitness, athletics, and the student health clinic")
    ]
    
    static let campusLingo: [GavinLingoItem] = [
        GavinLingoItem(term: "MUB", meaning: "Memorial Union Building", buildingId: "mub", details: "Student union with the Campus Store, MUB Commons dining, Ballroom, and Student Leadership & Involvement."),
        GavinLingoItem(term: "Wads", meaning: "Wadsworth Hall", buildingId: "wads", details: "Largest residence hall on US-41, home to the Dining Hall, Campus Cafe, and Residence Education & Housing Services."),
        GavinLingoItem(term: "MEEM", meaning: "Mechanical Engineering-Engineering Mechanics Building", buildingId: "meem", details: "Officially the R. L. Smith Building; campus tallest academic tower connected to the heated skywalk network."),
        GavinLingoItem(term: "SDC", meaning: "Student Development Complex", buildingId: "sdc", details: "Athletics, MacInnes Student Ice Arena, multipurpose gym, pool, fitness center, and health clinic."),
        GavinLingoItem(term: "Rekhi", meaning: "Kanwal & Ann Rekhi Hall", buildingId: "rekhi", details: "Home of the College of Computing, Computer Science, Applied Computing, and 24/7 student computing labs."),
        GavinLingoItem(term: "EERC", meaning: "Electrical Energy Resources Center", buildingId: "eerc", details: "Home to Electrical & Computer Engineering, Alley Makerspace, and robotics/automation labs."),
        GavinLingoItem(term: "AOB", meaning: "Academic Office Building", buildingId: "aob", details: "Home to the College of Business, Economics, Accounting, MIS, and Social Sciences."),
        GavinLingoItem(term: "DHH", meaning: "Douglass Houghton Hall", buildingId: "dhh", details: "Historic castle-style residence hall near Fisher Hall and the Library."),
        GavinLingoItem(term: "GLRC", meaning: "Great Lakes Research Center", buildingId: "glrc", details: "Waterfront research facility on the Portage Waterway."),
        GavinLingoItem(term: "M&M", meaning: "Minerals & Materials Engineering Building", buildingId: "mm", details: "Materials Science & Engineering, Psychology & Human Factors, and U05 Foundry Corridor.")
    ]
    
    static let daysInfo: [(code: String, label: String)] = [
        ("M", "Mon"), ("T", "Tue"), ("W", "Wed"), ("R", "Thu"), ("F", "Fri")
    ]
    
    init() {
        // Build phone lookup map from fallback contacts
        var phoneByEmail: [String: String] = [:]
        var officeByEmail: [String: String] = [:]
        for c in DirectoryViewModel.fallbackContacts {
            phoneByEmail[c.email.lowercased()] = c.phone
            if let off = c.office {
                officeByEmail[c.email.lowercased()] = off
            }
        }
        
        // Load bundled JSON dataset
        let bundleURL = Bundle.main.url(forResource: "GavinPrototypeData", withExtension: "json")
            ?? URL(fileURLWithPath: "/Users/jwk/Desktop/LociStoa/LociStoa/GavinPrototypeData.json")
        
        if let data = try? Data(contentsOf: bundleURL),
           let raw = try? JSONDecoder().decode(GavinRawBundle.self, from: data) {
            self.deptMeta = raw.DM
            self.subjects = raw.S.compactMap { pair in
                guard pair.count >= 2 else { return nil }
                return GavinSubject(code: pair[0], name: pair[1])
            }
            
            var parsedPeople: [GavinPerson] = []
            parsedPeople.reserveCapacity(raw.P.count)
            for (idx, p) in raw.P.enumerated() where p.count >= 7 {
                let name = p[0].stringValue
                let role = p[1].stringValue
                let dept = p[2].stringValue
                let rawOffice = p[3].stringValue
                let rawEmail = p[4].stringValue
                let email = rawEmail.contains("@") ? rawEmail : "\(rawEmail)@mtu.edu"
                let office = rawOffice.isEmpty ? (officeByEmail[email.lowercased()] ?? "Not listed") : rawOffice
                let phone = phoneByEmail[email.lowercased()] ?? "906-487-1885"
                let level = p[5].intValue
                let fac = p[6].intValue != 0
                
                let cleaned = name.replacingOccurrences(of: "[^A-Za-z .'-]", with: "", options: .regularExpression)
                let parts = cleaned.split(separator: " ").map(String.init).filter { !$0.isEmpty }
                let firstChar = parts.first?.first.map(String.init) ?? "?"
                let lastChar = parts.count > 1 ? (parts.last?.first.map(String.init) ?? "") : ""
                let initials = (firstChar + lastChar).uppercased()
                let hay = "\(name) \(role) \(dept) \(office)".lowercased()
                
                parsedPeople.append(
                    GavinPerson(
                        id: idx,
                        name: name,
                        role: role,
                        dept: dept,
                        office: office,
                        email: email,
                        phone: phone,
                        level: level,
                        fac: fac,
                        initials: initials,
                        hay: hay
                    )
                )
            }
            self.people = parsedPeople
            
            var counts: [String: Int] = [:]
            for person in parsedPeople {
                counts[person.dept, default: 0] += 1
            }
            self.depts = counts.keys.sorted().map { deptName in
                GavinDepartment(name: deptName, n: counts[deptName] ?? 0, hay: deptName.lowercased())
            }
            
            self.offices = raw.F
            
            var parsedOrgs: [GavinOrg] = []
            var catSet = Set<String>()
            for (idx, o) in raw.O.enumerated() where o.count >= 6 {
                let cat = o[0]
                let name = o[1]
                let short = o[2]
                let desc = o[3].isEmpty ? "No description listed." : o[3]
                let email = o[4]
                let site = o[5]
                catSet.insert(cat)
                parsedOrgs.append(
                    GavinOrg(
                        i: idx,
                        cat: cat,
                        name: name,
                        short: short,
                        desc: desc,
                        email: email,
                        site: site,
                        hay: "\(name) \(short) \(cat)".lowercased()
                    )
                )
            }
            self.orgs = parsedOrgs
            self.orgCatNames = catSet.sorted()
        } else {
            self.people = []
            self.depts = []
            self.deptMeta = [:]
            self.offices = []
            self.orgs = []
            self.orgCatNames = []
            self.subjects = []
        }
        
        // Restore persisted state from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(GavinSavedState.self, from: savedData) {
            if let thStr = saved.theme, let th = LociTheme(rawValue: thStr) {
                self.theme = th
            }
            self.widgets = saved.widgets ?? [:]
            self.favs = saved.favs ?? [:]
            self.classes = saved.classes ?? []
            self.tasks = saved.tasks ?? []
        }
        
        // Sync tasks with original ToDoList store ("data" in UserDefaults)
        syncFromToDoList()
        
        toDoList.$items
            .dropFirst()
            .sink { [weak self] newItems in
                guard let self, !self.isSyncingTasks else { return }
                self.syncTasksFromToDoItems(newItems)
            }
            .store(in: &cancellables)
        
        directoryVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Bidirectional Task Sync between ToDoList and GavinTaskItem
    static func formatDueDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
    
    private func syncFromToDoList() {
        if !toDoList.items.isEmpty {
            syncTasksFromToDoItems(toDoList.items)
        } else if !tasks.isEmpty {
            syncToDoItemsFromTasks()
        }
    }
    
    private func syncTasksFromToDoItems(_ items: [ToDoItem]) {
        isSyncingTasks = true
        defer { isSyncingTasks = false }
        self.tasks = items.enumerated().map { idx, item in
            GavinTaskItem(
                id: Int(item.id.uuidString.hashValue & 0x7FFFFFFF) + idx,
                type: item.priority.isEmpty ? "Assignment" : item.priority,
                course: item.classes.isEmpty ? "Other" : item.classes,
                description: item.description,
                dueDate: item.dueDate,
                due: Self.formatDueDate(item.dueDate),
                done: item.isCompleted,
                toDoItemId: item.id
            )
        }
    }
    
    private func syncToDoItemsFromTasks() {
        isSyncingTasks = true
        defer { isSyncingTasks = false }
        toDoList.items = tasks.map { t in
            ToDoItem(
                id: t.toDoItemId ?? UUID(),
                priority: t.type,
                classes: t.course,
                description: t.description,
                dueDate: t.dueDate ?? Date(),
                isCompleted: t.done
            )
        }
    }
    
    private func persistState() {
        let state = GavinSavedState(
            theme: theme.rawValue,
            widgets: widgets,
            favs: favs,
            classes: classes,
            tasks: tasks
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // MARK: - Effective Theme Colors (Supports AdminSettingsView Custom Tenant Branding)
    var effectiveBgColor: Color {
        customPrimaryBgColor ?? theme.bg
    }
    
    var effectiveAccentColor: Color {
        customSecondaryAccentColor ?? theme.accent
    }
    
    // MARK: - Navigation & Actions
    func go(
        _ targetTab: GavinTab,
        pv: GavinPeopleSubView? = nil,
        planMode: GavinPlanMode? = nil,
        resetPeopleSelection: Bool = false,
        dept: String?? = nil,
        office: String?? = nil,
        org: Int?? = nil,
        building: String? = nil,
        floor: String? = nil,
        layer: String? = nil
    ) {
        withAnimation(.easeOut(duration: 0.22)) {
            self.tab = targetTab
            self.sheet = nil
            if resetPeopleSelection {
                self.dept = nil
                self.office = nil
                self.org = nil
            }
            if let pv { self.pv = pv }
            if let planMode { self.planMode = planMode }
            if let dept { self.dept = dept }
            if let office { self.office = office }
            if let org { self.org = org }
            if let building { self.building = building }
            if let floor { self.floor = floor }
            if let layer { self.layer = layer }
        }
        
        if targetTab == .people && self.pv == .dir {
            triggerDirectoryLoadingShimmer()
        }
    }
    
    func triggerDirectoryLoadingShimmer() {
        loadTask?.cancel()
        dirLoading = true
        loadTask = Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                self.dirLoading = false
            }
        }
    }
    
    func isWidgetEnabled(_ key: String) -> Bool {
        if let val = widgets[key] { return val }
        return Self.widgetDefinitions.first(where: { $0.key == key })?.defaultOn ?? false
    }
    
    func toggleWidget(_ key: String) {
        withAnimation(.easeInOut(duration: 0.18)) {
            let current = isWidgetEnabled(key)
            widgets[key] = !current
        }
    }
    
    func toggleTask(_ id: Int) {
        var nowDone = false
        tasks = tasks.map { t in
            guard t.id == id else { return t }
            nowDone = !t.done
            var copy = t
            copy.done = nowDone
            return copy
        }
        syncToDoItemsFromTasks()
        
        toastTask?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            toast = nowDone ? (text: "Marked done", id: id) : nil
        }
        if nowDone {
            toastTask = Task {
                try? await Task.sleep(nanoseconds: 4_500_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    self.toast = nil
                }
            }
        }
    }
    
    func deleteTask(_ id: Int) {
        withAnimation(.easeOut(duration: 0.2)) {
            tasks.removeAll { $0.id == id }
            syncToDoItemsFromTasks()
        }
    }
    
    func moveTasks(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        syncToDoItemsFromTasks()
    }
    
    func undoToast() {
        if let currentToast = toast {
            toggleTask(currentToast.id)
        }
    }
    
    func openPersonSheet(_ person: GavinPerson) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            contactId = person.id
            sheet = .contact
        }
    }
    
    func toggleFavForCurrentContact() {
        guard let cur = currentContact else { return }
        let isFav = favs[cur.email] ?? false
        favs[cur.email] = !isFav
    }
    
    /// Converts a GavinPerson into a Contact for deep-linking into MapView / MTUIndoorMapView
    func contactForPerson(_ person: GavinPerson) -> Contact {
        if let match = directoryVM.contacts.first(where: {
            $0.email.caseInsensitiveCompare(person.email) == .orderedSame ||
            $0.name.caseInsensitiveCompare(person.name) == .orderedSame
        }) {
            return match
        }
        return Contact(
            id: "gavin-\(person.id)",
            name: person.name,
            role: person.role,
            department: person.dept,
            email: person.email,
            phone: person.phone,
            office: person.office == "Not listed" ? nil : person.office
        )
    }
    
    /// Opens the interactive MapView & MTUIndoorMapView routed directly to a contact's office
    func locateContactOnInteractiveMap(_ contact: Contact) {
        withAnimation(.easeOut(duration: 0.2)) {
            sheet = nil
            focusedMapContact = contact
        }
    }
    
    func locatePersonOnInteractiveMap(_ person: GavinPerson) {
        let contact = contactForPerson(person)
        locateContactOnInteractiveMap(contact)
    }
    
    func contactToMap() {
        var matchedBld: String? = nil
        if let cur = currentContact {
            let lowerOff = cur.office.lowercased()
            for b in Self.mapBuildings {
                if lowerOff.contains(b.short.lowercased()) || lowerOff.contains(b.name.lowercased()) {
                    matchedBld = b.id
                    break
                }
            }
        }
        mapMode = .diagram
        go(.map, building: matchedBld, floor: "1F", layer: "All")
    }
    
    func contactToDept() {
        guard let cur = currentContact else { return }
        go(.people, pv: .depts, resetPeopleSelection: true, dept: cur.dept)
    }
    
    func openAddTaskSheet() {
        addType = "Assignment"
        addCourse = nil
        addDescription = ""
        addDueDate = Date()
        addHasDueDate = true
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            sheet = .add
        }
    }
    
    func openAddClassSheet() {
        cSubj = nil
        cSubjQuery = ""
        cNum = ""
        cDays = [:]
        cStart = "10:00"
        cEnd = "10:50"
        cLoc = ""
        cErr = ""
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            sheet = .classSheet
        }
    }
    
    func saveClass() {
        let typed = cSubjQuery.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let isCodeRegex = typed.range(of: "^[A-Z]{2,5}$", options: .regularExpression) != nil
        let subj = cSubj ?? (isCodeRegex ? typed : "")
        let num = cNum.trimmingCharacters(in: .whitespacesAndNewlines)
        let days = Self.daysInfo.map(\.code).filter { cDays[$0] == true }.joined()
        
        var err = ""
        if subj.isEmpty {
            err = "Pick a subject from the list, or type its code."
        } else if num.isEmpty {
            err = "Enter the course number."
        } else if days.isEmpty {
            err = "Choose at least one day."
        } else if cStart.isEmpty || cEnd.isEmpty || Self.mins(cEnd) <= Self.mins(cStart) {
            err = "The end time has to be after the start time."
        }
        
        if !err.isEmpty {
            cErr = err
            return
        }
        
        let newClass = GavinClassItem(
            id: Int(Date().timeIntervalSince1970 * 1000),
            subj: subj,
            num: num,
            days: days,
            start: cStart,
            end: cEnd,
            loc: cLoc.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        classes.append(newClass)
        withAnimation(.easeOut(duration: 0.22)) {
            sheet = nil
        }
    }
    
    func removeClass(_ id: Int) {
        withAnimation(.easeOut(duration: 0.2)) {
            classes.removeAll { $0.id == id }
        }
    }
    
    func saveTask() {
        let chosenCourse = selectedAddCourse
        let trimmedDesc = addDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let dueText = addHasDueDate ? Self.formatDueDate(addDueDate) : "No date"
        let newUUID = UUID()
        let newTask = GavinTaskItem(
            id: Int(Date().timeIntervalSince1970 * 1000),
            type: addType,
            course: chosenCourse,
            description: trimmedDesc,
            dueDate: addHasDueDate ? addDueDate : nil,
            due: dueText,
            done: false,
            toDoItemId: newUUID
        )
        tasks.append(newTask)
        syncToDoItemsFromTasks()
        withAnimation(.easeOut(duration: 0.22)) {
            sheet = nil
        }
    }
    
    // MARK: - Formatting & Computed Helpers (Exact match to renderVals() in Main.dc.html)
    static func fmt(_ timeStr: String) -> String {
        let parts = timeStr.split(separator: ":")
        let h = Int(parts.first ?? "0") ?? 0
        let m = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        let h12 = (h % 12 == 0) ? 12 : (h % 12)
        let mPad = m < 10 ? "0\(m)" : "\(m)"
        let ampm = h >= 12 ? "PM" : "AM"
        return "\(h12):\(mPad) \(ampm)"
    }
    
    static func mins(_ timeStr: String) -> Int {
        let parts = timeStr.split(separator: ":")
        let h = Int(parts.first ?? "0") ?? 0
        let m = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        return h * 60 + m
    }
    
    func subjName(for code: String) -> String {
        subjects.first(where: { $0.code == code })?.name ?? "Other subject"
    }
    
    var sortedClasses: [(item: GavinClassItem, code: String, name: String, time: String, when: String)] {
        classes.sorted { Self.mins($0.start) < Self.mins($1.start) }.map { k in
            let code = "\(k.subj) \(k.num)"
            let dayText = Self.daysInfo.filter { k.days.contains($0.code) }.map(\.label).joined(separator: ", ")
            let time = "\(Self.fmt(k.start)) – \(Self.fmt(k.end))"
            let locSuffix = k.loc.isEmpty ? "" : " · \(k.loc)"
            let when = "\(dayText) · \(time)\(locSuffix)"
            return (k, code, subjName(for: k.subj), time, when)
        }
    }
    
    var todayText: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "EEEE, MMMM d"
        return df.string(from: Date())
    }
    
    var nextClassInfo: (code: String, line: String, label: String)? {
        let now = Date()
        let cal = Calendar.current
        let nowMin = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        let jsDay = cal.component(.weekday, from: now) - 1
        let letters = ["", "M", "T", "W", "R", "F", ""]
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let allSorted = sortedClasses
        for d in 0..<7 {
            let wd = (jsDay + d) % 7
            let letter = letters[wd]
            if letter.isEmpty { continue }
            let todays = allSorted.filter { entry in
                entry.item.days.contains(letter) && (d > 0 || Self.mins(entry.item.end) > nowMin)
            }
            if let first = todays.first {
                let live = (d == 0 && Self.mins(first.item.start) <= nowMin)
                let locSuffix = first.item.loc.isEmpty ? "" : " · \(first.item.loc)"
                let line = "\(first.time)\(locSuffix)"
                let dayLabel = (d == 0) ? "Today" : (d == 1 ? "Tomorrow" : dayNames[wd])
                let label = live ? "Happening now" : "Up next · \(dayLabel)"
                return (first.code, line, label)
            }
        }
        return nil
    }
    
    var selectedCalDayIndex: Int {
        if let calDay { return calDay }
        let jsDay = Calendar.current.component(.weekday, from: Date()) - 1
        return (jsDay >= 1 && jsDay <= 5) ? (jsDay - 1) : 0
    }
    
    var weekCalendarDays: [(index: Int, top: String, num: Int, dots: String, on: Bool)] {
        let now = Date()
        let cal = Calendar.current
        let dow = cal.component(.weekday, from: now) - 1
        let offsetToMonday = (dow == 0) ? 1 : (dow == 6 ? 2 : (1 - dow))
        let startOfToday = cal.startOfDay(for: now)
        let monday = cal.date(byAdding: .day, value: offsetToMonday, to: startOfToday) ?? startOfToday
        let sel = selectedCalDayIndex
        
        return Self.daysInfo.enumerated().map { i, d in
            let date = cal.date(byAdding: .day, value: i, to: monday) ?? monday
            let isToday = cal.isDate(date, inSameDayAs: now)
            let dayNum = cal.component(.day, from: date)
            let count = classes.filter { $0.days.contains(d.code) }.count
            let dots = String(repeating: "•", count: min(count, 4))
            return (i, isToday ? "Today" : d.label, dayNum, dots, sel == i)
        }
    }
    
    var selectedCalDayClasses: [(item: GavinClassItem, code: String, name: String, time: String, when: String)] {
        let sel = selectedCalDayIndex
        let code = Self.daysInfo[sel].code
        return sortedClasses.filter { $0.item.days.contains(code) }
    }
    
    var calEmptyText: String {
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let sel = selectedCalDayIndex
        return classes.isEmpty ? "Add your classes to fill in the week." : "No classes on \(dayNames[sel + 1])."
    }
    
    var dueSoonTasks: [GavinTaskItem] {
        Array(tasks.filter { !$0.done }.prefix(3))
    }
    
    var courseOptionsForTask: [String] {
        var opts: [String] = []
        for entry in sortedClasses {
            if !opts.contains(entry.code) {
                opts.append(entry.code)
            }
        }
        // Include original AddItemView courses as well
        for preset in ["MIS3100", "MIS4000", "HU2130", "HU2700", "Other"] {
            if !opts.contains(preset) {
                opts.append(preset)
            }
        }
        return opts
    }
    
    var selectedAddCourse: String {
        let opts = courseOptionsForTask
        if let addCourse, opts.contains(addCourse) {
            return addCourse
        }
        return opts.first ?? "Other"
    }
    
    var subjectAutocompleteMatches: [GavinSubject] {
        guard cSubj == nil else { return [] }
        let sq = cSubjQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !sq.isEmpty else { return [] }
        return Array(
            subjects.filter {
                $0.code.lowercased().hasPrefix(sq) || $0.name.lowercased().contains(sq)
            }.prefix(6)
        )
    }
    
    // Directory Filtering
    var filteredDirectoryPeople: [GavinPerson] {
        let dq = dirQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return people.filter { c in
            let matchesRole = (filter == "All") || ((filter == "Faculty") == c.fac)
            let matchesQuery = dq.isEmpty || c.hay.contains(dq)
            return matchesRole && matchesQuery
        }
    }
    
    var visibleDirectoryPeople: [GavinPerson] {
        Array(filteredDirectoryPeople.prefix(capLimit))
    }
    
    var dirCountText: String {
        let total = filteredDirectoryPeople.count
        if total > capLimit {
            return "Showing \(capLimit) of \(total). Search to narrow it down."
        }
        return "\(total) \(total == 1 ? "person" : "people")"
    }
    
    var currentContact: GavinPerson? {
        guard let contactId, contactId >= 0, contactId < people.count else { return nil }
        return people[contactId]
    }
    
    var savedContacts: [GavinPerson] {
        people.filter { favs[$0.email] == true }
    }
    
    // Departments Filtering
    var filteredDepartments: [GavinDepartment] {
        let dpq = deptQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return depts.filter { dpq.isEmpty || $0.hay.contains(dpq) }
    }
    
    var visibleDepartments: [GavinDepartment] {
        Array(filteredDepartments.prefix(capLimit))
    }
    
    var deptCountText: String {
        let total = filteredDepartments.count
        if total > capLimit {
            return "Showing \(capLimit) of \(total). Search to narrow it down."
        }
        return "\(total) \(total == 1 ? "department" : "departments")"
    }
    
    var currentDeptPeopleGrouped: [(person: GavinPerson, showHead: Bool, head: String, isFirstInGroup: Bool)] {
        guard let dept else { return [] }
        let members = people.filter { $0.dept == dept }.sorted {
            if $0.level != $1.level { return $0.level < $1.level }
            return $0.name < $1.name
        }
        let groups: [(String, (GavinPerson) -> Bool)] = [
            ("Leadership", { $0.level <= 8 }),
            ("Faculty", { $0.level > 8 && $0.fac }),
            ("Staff", { $0.level > 8 && !$0.fac })
        ]
        var result: [(GavinPerson, Bool, String, Bool)] = []
        for (groupName, predicate) in groups {
            let groupMembers = members.filter(predicate)
            for (i, person) in groupMembers.enumerated() {
                result.append((person, i == 0, groupName, i == 0))
            }
        }
        return result
    }
    
    // Help Offices Filtering
    var filteredHelpOffices: [(office: GavinOffice, showHead: Bool)] {
        let hq = helpQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let matches = offices.filter { hq.isEmpty || $0.hay.contains(hq) }
        return matches.enumerated().map { idx, off in
            let first = (idx == 0) || (matches[idx - 1].category != off.category)
            return (off, first)
        }
    }
    
    var currentOffice: GavinOffice? {
        guard let office else { return nil }
        return offices.first(where: { $0.id == office })
    }
    
    // Student Orgs Filtering
    var filteredOrgs: [GavinOrg] {
        let oq = orgQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return orgs.filter { o in
            let matchesCat = (orgCat == "All") || (o.cat == orgCat)
            let matchesQuery = oq.isEmpty || o.hay.contains(oq)
            return matchesCat && matchesQuery
        }
    }
    
    var visibleOrgs: [GavinOrg] {
        Array(filteredOrgs.prefix(capLimit))
    }
    
    var orgCountText: String {
        let total = filteredOrgs.count
        if total > capLimit {
            return "Showing \(capLimit) of \(total). Search to narrow it down."
        }
        return "\(total) \(total == 1 ? "organization" : "organizations")"
    }
    
    var currentOrg: GavinOrg? {
        guard let org, org >= 0, org < orgs.count else { return nil }
        return orgs[org]
    }
    
    var orgOfTheDay: GavinOrg? {
        guard !orgs.isEmpty else { return nil }
        let dayIndex = Int(Date().timeIntervalSince1970 / 86400) % orgs.count
        return orgs[dayIndex]
    }
    
    var selectedMapBuilding: GavinMapBuilding? {
        guard let building else { return nil }
        return Self.mapBuildings.first(where: { $0.id == building })
    }
    
    // Tools & Global Search Hits (Includes all 8 Original Dashboard Tools + Gavin Tools)
    var toolShortcuts: [GavinToolShortcut] {
        [
            GavinToolShortcut(label: "Live Interactive Map", sub: "GPS, heated skywalks & indoor blueprints", icon: .map, kw: "live interactive map building skywalk indoor blueprint floor directions room") { [weak self] in
                self?.mapMode = .interactive
                self?.go(.map)
            },
            GavinToolShortcut(label: "Directory Contacts", sub: "Faculty, staff & office locator", icon: .people, kw: "directory people contacts faculty staff professor server") { [weak self] in
                self?.go(.people, pv: .dir, resetPeopleSelection: true)
            },
            GavinToolShortcut(label: "Task Flow Planner", sub: "Assignments, descriptions & due dates", icon: .planner, kw: "planner tasks homework assignment exam taskflow") { [weak self] in
                self?.go(.planner, planMode: .tasks)
            },
            GavinToolShortcut(label: "Course Schedule", sub: "My classes & 8-period Friday schedule", icon: .clock, kw: "classes course schedule class times friday period") { [weak self] in
                self?.go(.planner, planMode: .periods)
            },
            GavinToolShortcut(label: "Career Fair", sub: "Search attending companies & booths", icon: .briefcase, kw: "career fair companies booths ford stryker dow caterpillar gm oshkosh") { [weak self] in
                self?.sheet = nil
                self?.activeDashboardSheet = .careerFair
            },
            GavinToolShortcut(label: "Common Links", sub: "MyMichiganTech, Canvas, Banweb", icon: .link, kw: "links canvas banweb mymichigantech calendar") { [weak self] in
                self?.sheet = nil
                self?.activeDashboardSheet = .links
            },
            GavinToolShortcut(label: "Ask LociStoa Chatbot", sub: "Campus AI assistant", icon: .chat, kw: "chatbot ask locistoa assistant questions help") { [weak self] in
                self?.sheet = nil
                self?.activeDashboardSheet = .chatbot
            },
            GavinToolShortcut(label: "Campus Nomenclature", sub: "MTU lingo & building nicknames", icon: .book, kw: "nomenclature lingo nicknames mub wads meem sdc") { [weak self] in
                self?.sheet = nil
                self?.activeDashboardSheet = .nomenclature
            },
            GavinToolShortcut(label: "Get help", sub: "Find the right office", icon: .help, kw: "who to ask help office problem") { [weak self] in
                self?.go(.people, pv: .help, resetPeopleSelection: true)
            },
            GavinToolShortcut(label: "Departments", sub: "People by department", icon: .more, kw: "departments college office") { [weak self] in
                self?.go(.people, pv: .depts, resetPeopleSelection: true)
            },
            GavinToolShortcut(label: "Student orgs", sub: "Clubs and organizations", icon: .flag, kw: "student organizations clubs greek sports") { [weak self] in
                self?.go(.people, pv: .orgs, resetPeopleSelection: true)
            },
            GavinToolShortcut(label: "Emergency numbers", sub: "911 and campus lines", icon: .phone, kw: "emergency 911 988 police safety counseling") { [weak self] in
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    self?.sheet = .emergency
                }
            }
        ]
    }
    
    var searchLingoHits: [GavinLingoItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return Self.campusLingo.filter { "\($0.term) \($0.meaning) \($0.details)".lowercased().contains(q) }
    }
    
    var searchOfficeHits: [GavinOffice] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return Array(offices.filter { $0.hay.contains(q) }.prefix(4))
    }
    
    var searchPeopleHits: [GavinPerson] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return Array(people.filter { $0.hay.contains(q) }.prefix(5))
    }
    
    var searchOrgHits: [GavinOrg] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return Array(orgs.filter { $0.hay.contains(q) }.prefix(4))
    }
    
    var searchToolHits: [GavinToolShortcut] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return toolShortcuts.filter { "\($0.label) \($0.kw)".lowercased().contains(q) }
    }
    
    var searchNoHits: Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return false }
        return searchLingoHits.isEmpty
            && searchOfficeHits.isEmpty
            && searchPeopleHits.isEmpty
            && searchOrgHits.isEmpty
            && searchToolHits.isEmpty
    }
}
