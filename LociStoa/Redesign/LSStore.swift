import Foundation
import Combine

// LociStoa redesign: the app's memory and logic.
//
// LSStore keeps track of what the student is doing (which tab, what they typed, what they saved)
// and works out what each screen should show. The screens only draw what the store gives them.
// Anything marked @Published redraws the screens when it changes.

// MARK: - Small types the store uses

enum LSTab: String {
    case home, people, help, map, planner, more
}

/// The views inside the People tab (dir, depts, orgs) and the Help tab (help, tutor).
enum LSPane: String {
    case dir, depts, orgs, help, tutor

    var isHelpish: Bool { self == .help || self == .tutor }
}

enum LSPlanMode: String {
    case tasks, times
}

/// The panels that slide up from the bottom.
enum LSSheet: String, Identifiable {
    case emergency, contact, addTask, addClass, search

    var id: String { rawValue }
}

struct LSToast: Equatable {
    let token = UUID()
    let text: String
    let taskID: UUID
}

/// A class with its text already worked out for the screens.
struct LSClassRow: Identifiable {
    let cls: LSClass
    let code: String        // "MIS 4000"
    let name: String        // "Management Information Systems"
    let time: String        // "10:00 AM – 10:50 AM"
    let when: String        // "Mon, Wed · 10:00 AM – 10:50 AM · Fisher 135"
    let helpCenter: LSCenter?

    var id: UUID { cls.id }
}

struct LSNextClass {
    let label: String
    let code: String
    let line: String
}

struct LSWeekDay: Identifiable {
    let id: Int             // 0 = Monday ... 4 = Friday
    let top: String         // "Mon" or "Today"
    let num: Int            // day of the month
    let dots: String        // one dot per class, up to four
    let spoken: String      // what VoiceOver reads
}

/// A row in a list that is split into groups. `head` is set on the first row of each group.
struct LSGroupRow: Identifiable {
    let id: String
    let title: String
    let sub: String
    let head: String?
}

struct LSDeptPerson: Identifiable {
    let person: LSPerson
    let head: String?

    var id: Int { person.id }
}

/// A shortcut to somewhere in the app. Shown in search results and on the home screen.
struct LSTool: Identifiable {
    enum Action {
        case directory, getHelp, map, links, departments, tutoring, orgs, tasks, classes, emergency
    }

    let id: String
    let label: String
    let sub: String
    let icon: String        // SF Symbol name
    let keywords: String
    let action: Action
}

// MARK: - The store

final class LSStore: ObservableObject {
    let data = LSCampusData()

    // Where the student is
    @Published var tab: LSTab = .home
    @Published var pane: LSPane = .dir
    @Published var planMode: LSPlanMode = .tasks
    @Published var sheet: LSSheet?
    var prevTab: LSTab = .home

    // People tab
    @Published var dirQuery = ""
    @Published var filter = "All"
    @Published var dept: String?
    @Published var deptQuery = ""
    @Published var orgIndex: Int?
    @Published var orgQuery = ""
    @Published var orgCat = "All"
    @Published var contactID: Int?

    // Help tab
    @Published var officeID: String?
    @Published var helpQuery = ""
    @Published var centerID: String?
    @Published var tutorQuery = ""
    @Published var confirmNumber: LSNumber?

    // Map tab
    @Published var layer = "All"
    @Published var building: String?
    @Published var floor = "1F"

    // Home and search
    @Published var calDay: Int?
    @Published var query = ""
    @Published var toast: LSToast?

    // Saved on this phone
    @Published var classes: [LSClass] { didSet { save() } }
    @Published var tasks: [LSTask] { didSet { save() } }
    @Published var favs: Set<String> { didSet { save() } }
    @Published var themeID: String { didSet { save() } }
    @Published var widgets: [String: Bool] { didSet { save() } }

    private static let saveKey = "locistoa-redesign-v1"
    static let cap = 40     // longest list we show before asking the student to search

    init() {
        var saved = LSSaved()
        if let raw = UserDefaults.standard.data(forKey: LSStore.saveKey),
           let decoded = try? JSONDecoder().decode(LSSaved.self, from: raw) {
            saved = decoded
        }
        classes = saved.classes
        tasks = saved.tasks
        favs = Set(saved.favs)
        themeID = saved.theme
        widgets = saved.widgets
    }

    private func save() {
        let saved = LSSaved(classes: classes, tasks: tasks, favs: favs.sorted(), theme: themeID, widgets: widgets)
        if let raw = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(raw, forKey: LSStore.saveKey)
        }
    }

    // MARK: Moving around

    /// Switch tabs from the tab bar.
    func go(_ newTab: LSTab) {
        if newTab == .help && !pane.isHelpish {
            pane = .help
        }
        if newTab == .people && pane.isHelpish {
            pane = .dir
        }
        if newTab == .planner && tab != .planner {
            prevTab = tab
        }
        sheet = nil
        tab = newTab
    }

    /// Jump to a view in the People or Help tab, optionally straight to one item.
    func openPeople(_ newPane: LSPane, dept: String? = nil, office: String? = nil, org: Int? = nil, center: String? = nil) {
        self.dept = dept
        self.officeID = office
        self.orgIndex = org
        self.centerID = center
        pane = newPane
        sheet = nil
        tab = newPane.isHelpish ? .help : .people
    }

    /// Switch between the views inside the People or Help tab.
    func pickPane(_ newPane: LSPane) {
        openPeople(newPane)
    }

    func openMap(building id: String? = nil) {
        if let id = id, !id.isEmpty {
            building = id
            floor = "1F"
            layer = "All"
        }
        sheet = nil
        tab = .map
    }

    func openPlanner(_ mode: LSPlanMode) {
        planMode = mode
        go(.planner)
    }

    func openContact(_ person: LSPerson) {
        contactID = person.id
        sheet = .contact
    }

    func openSearch() {
        query = ""
        sheet = .search
    }

    /// The Tutoring office row opens the tutoring list instead of an office page.
    func openOffice(_ id: String) {
        if id == "learning" {
            openPeople(.tutor)
        } else {
            openPeople(.help, office: id)
        }
    }

    func run(_ tool: LSTool) {
        switch tool.action {
        case .directory: openPeople(.dir)
        case .getHelp: openPeople(.help)
        case .map: openMap()
        case .links: go(.more)
        case .departments: openPeople(.depts)
        case .tutoring: openPeople(.tutor)
        case .orgs: openPeople(.orgs)
        case .tasks: openPlanner(.tasks)
        case .classes: openPlanner(.times)
        case .emergency: sheet = .emergency
        }
    }

    // MARK: Directory

    private func clean(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespaces).lowercased()
    }

    var dirMatches: [LSPerson] {
        let q = clean(dirQuery)
        return data.people.filter { p in
            let passesFilter = filter == "All" || (filter == "Faculty") == p.isFaculty
            return passesFilter && (q.isEmpty || p.hay.contains(q))
        }
    }

    func countText(_ total: Int, one: String, many: String) -> String {
        if total > LSStore.cap {
            return "Showing \(LSStore.cap) of \(total). Search to narrow it down."
        }
        return "\(total) \(total == 1 ? one : many)"
    }

    var currentPerson: LSPerson? {
        guard let id = contactID, id >= 0, id < data.people.count else { return nil }
        return data.people[id]
    }

    var favPeople: [LSPerson] {
        data.people.filter { favs.contains($0.email) }
    }

    func isFav(_ person: LSPerson) -> Bool {
        favs.contains(person.email)
    }

    func toggleFav(_ person: LSPerson) {
        if favs.contains(person.email) {
            favs.remove(person.email)
        } else {
            favs.insert(person.email)
        }
    }

    // MARK: Departments

    var deptMatches: [LSDept] {
        let q = clean(deptQuery)
        return data.depts.filter { q.isEmpty || $0.hay.contains(q) }
    }

    /// Everyone in the open department: leadership first, then faculty, then staff.
    var deptPeople: [LSDeptPerson] {
        guard let dept = dept else { return [] }
        let members = data.people
            .filter { $0.dept == dept }
            .sorted { a, b in
                if a.level != b.level { return a.level < b.level }
                return a.name < b.name
            }
        var rows: [LSDeptPerson] = []
        let groups: [(String, (LSPerson) -> Bool)] = [
            ("Leadership", { $0.level <= 8 }),
            ("Faculty", { $0.level > 8 && $0.isFaculty }),
            ("Staff", { $0.level > 8 && !$0.isFaculty }),
        ]
        for group in groups {
            let matching = members.filter(group.1)
            for (index, person) in matching.enumerated() {
                rows.append(LSDeptPerson(person: person, head: index == 0 ? group.0 : nil))
            }
        }
        return rows
    }

    var deptCategory: String {
        guard let dept = dept, let meta = data.deptMeta[dept] else { return "" }
        return meta.category
    }

    var deptReportsTo: String {
        guard let dept = dept, let meta = data.deptMeta[dept] else { return "" }
        return meta.reportsTo
    }

    // MARK: Help (offices)

    var helpRows: [LSGroupRow] {
        let q = clean(helpQuery)
        let matches = data.offices.filter { q.isEmpty || $0.hay.contains(q) }
        var rows: [LSGroupRow] = []
        for (index, office) in matches.enumerated() {
            let first = index == 0 || matches[index - 1].category != office.category
            rows.append(LSGroupRow(id: office.id, title: office.goHereFor, sub: office.name, head: first ? office.category : nil))
        }
        return rows
    }

    var currentOffice: LSOffice? {
        guard let id = officeID else { return nil }
        return data.offices.first { $0.id == id }
    }

    // MARK: Tutoring (learning centers)

    func place(_ center: LSCenter) -> String {
        center.room.isEmpty ? center.building : center.building + " " + center.room
    }

    var tutorRows: [LSGroupRow] {
        let q = clean(tutorQuery)
        let matches = data.centers.filter { q.isEmpty || $0.hay.contains(q) }
        var rows: [LSGroupRow] = []
        for (index, center) in matches.enumerated() {
            let first = index == 0 || matches[index - 1].category != center.category
            rows.append(LSGroupRow(id: center.id, title: center.name, sub: place(center), head: first ? center.category : nil))
        }
        return rows
    }

    var currentCenter: LSCenter? {
        guard let id = centerID else { return nil }
        return data.centers.first { $0.id == id }
    }

    // MARK: Student orgs

    var orgMatches: [LSOrg] {
        let q = clean(orgQuery)
        return data.orgs.filter { o in
            (orgCat == "All" || o.category == orgCat) && (q.isEmpty || o.hay.contains(q))
        }
    }

    var currentOrg: LSOrg? {
        guard let index = orgIndex, index >= 0, index < data.orgs.count else { return nil }
        return data.orgs[index]
    }

    /// A different org every day.
    var orgOfTheDay: LSOrg? {
        guard !data.orgs.isEmpty else { return nil }
        let day = Int(Date().timeIntervalSince1970 / 86400)
        return data.orgs[day % data.orgs.count]
    }

    // MARK: Classes

    static let days: [(letter: String, short: String, full: String)] = [
        ("M", "Mon", "Monday"),
        ("T", "Tue", "Tuesday"),
        ("W", "Wed", "Wednesday"),
        ("R", "Thu", "Thursday"),
        ("F", "Fri", "Friday"),
    ]

    /// "13:05" -> minutes since midnight
    static func minutes(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        let h = parts.count > 0 ? Int(parts[0]) ?? 0 : 0
        let m = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
        return h * 60 + m
    }

    /// "13:05" -> "1:05 PM"
    static func clock(_ time: String) -> String {
        let total = minutes(time)
        let h = total / 60
        let m = total % 60
        let hour12 = h % 12 == 0 ? 12 : h % 12
        return "\(hour12):\(m < 10 ? "0" : "")\(m) \(h >= 12 ? "PM" : "AM")"
    }

    /// A time today, used as the starting value of the time pickers. time(10, 0) is 10:00 AM.
    static func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    /// A picked time -> "13:05", the way classes are saved.
    static func hhmm(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        let h = parts.hour ?? 0
        let m = parts.minute ?? 0
        return "\(h < 10 ? "0" : "")\(h):\(m < 10 ? "0" : "")\(m)"
    }

    func subjectName(_ code: String) -> String {
        data.subjects.first { $0.code == code }?.name ?? "Other subject"
    }

    var classRows: [LSClassRow] {
        classes
            .sorted { LSStore.minutes($0.start) < LSStore.minutes($1.start) }
            .map { k in
                let time = LSStore.clock(k.start) + " – " + LSStore.clock(k.end)
                let dayText = LSStore.days
                    .filter { k.days.contains($0.letter) }
                    .map { $0.short }
                    .joined(separator: ", ")
                return LSClassRow(
                    cls: k,
                    code: k.subj + " " + k.num,
                    name: subjectName(k.subj),
                    time: time,
                    when: dayText + " · " + time + (k.loc.isEmpty ? "" : " · " + k.loc),
                    helpCenter: data.centers.first { $0.codes.contains(k.subj) }
                )
            }
    }

    func removeClass(_ id: UUID) {
        classes.removeAll { $0.id == id }
    }

    /// Checks the Add class form. Returns an error message, or nil after saving the class.
    func addClass(subject: String, typed: String, number: String, days: Set<String>, start: String, end: String, location: String) -> String? {
        var subj = subject
        if subj.isEmpty {
            let code = typed.trimmingCharacters(in: .whitespaces).uppercased()
            let lettersOnly = !code.isEmpty && code.unicodeScalars.allSatisfy { $0.value >= 65 && $0.value <= 90 }
            if lettersOnly && code.count >= 2 && code.count <= 5 {
                subj = code
            }
        }
        let num = number.trimmingCharacters(in: .whitespaces)
        let dayLetters = LSStore.days.map { $0.letter }.filter { days.contains($0) }.joined()

        if subj.isEmpty { return "Pick a subject from the list, or type its code." }
        if num.isEmpty { return "Enter the course number." }
        if dayLetters.isEmpty { return "Choose at least one day." }
        if LSStore.minutes(end) <= LSStore.minutes(start) { return "The end time has to be after the start time." }

        classes.append(LSClass(subj: subj, num: num, days: dayLetters, start: start, end: end, loc: location.trimmingCharacters(in: .whitespaces)))
        return nil
    }

    func subjectMatches(_ typed: String) -> [LSSubject] {
        let q = clean(typed)
        guard !q.isEmpty else { return [] }
        // Codes that start with what was typed come first, then subjects whose name contains it.
        let byCode = data.subjects.filter { $0.code.lowercased().hasPrefix(q) }
        let byName = data.subjects.filter { !$0.code.lowercased().hasPrefix(q) && $0.name.lowercased().contains(q) }
        return Array((byCode + byName).prefix(6))
    }

    // MARK: Home screen

    /// 0 = Sunday ... 6 = Saturday
    private var todayIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    /// The class happening now, or the next one coming up this week.
    var nextClass: LSNextClass? {
        let rows = classRows
        let now = Date()
        let calendar = Calendar.current
        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let letters = ["", "M", "T", "W", "R", "F", ""]
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        for offset in 0..<7 {
            let weekday = (todayIndex + offset) % 7
            let letter = letters[weekday]
            if letter.isEmpty { continue }
            let todays = rows.filter { row in
                row.cls.days.contains(letter) && (offset > 0 || LSStore.minutes(row.cls.end) > nowMinutes)
            }
            if let row = todays.first {
                let live = offset == 0 && LSStore.minutes(row.cls.start) <= nowMinutes
                let dayLabel = offset == 0 ? "Today" : (offset == 1 ? "Tomorrow" : dayNames[weekday])
                return LSNextClass(
                    label: live ? "Happening now" : "Up next · " + dayLabel,
                    code: row.code,
                    line: row.time + (row.cls.loc.isEmpty ? "" : " · " + row.cls.loc)
                )
            }
        }
        return nil
    }

    var todayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    /// Which day of the week card is picked: the one tapped, or today (Monday on weekends).
    var calSelected: Int {
        if let picked = calDay { return picked }
        let today = todayIndex
        return today >= 1 && today <= 5 ? today - 1 : 0
    }

    /// Monday to Friday of this week (next week if it is the weekend).
    var weekDays: [LSWeekDay] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let today = todayIndex
        let toMonday = today == 0 ? 1 : (today == 6 ? 2 : 1 - today)
        let monday = calendar.date(byAdding: .day, value: toMonday, to: startOfToday) ?? startOfToday
        let rows = classRows

        var result: [LSWeekDay] = []
        for (index, day) in LSStore.days.enumerated() {
            let date = calendar.date(byAdding: .day, value: index, to: monday) ?? monday
            let count = rows.filter { $0.cls.days.contains(day.letter) }.count
            result.append(LSWeekDay(
                id: index,
                top: calendar.isDateInToday(date) ? "Today" : day.short,
                num: calendar.component(.day, from: date),
                dots: String(repeating: "•", count: min(count, 4)),
                spoken: "\(day.full), \(count) \(count == 1 ? "class" : "classes")"
            ))
        }
        return result
    }

    var calList: [LSClassRow] {
        let letter = LSStore.days[calSelected].letter
        return classRows.filter { $0.cls.days.contains(letter) }
    }

    var calEmptyText: String {
        classes.isEmpty ? "Add your classes to fill in the week." : "No classes on \(LSStore.days[calSelected].full)."
    }

    static let helpChips: [(label: String, office: String)] = [
        ("Transcript", "registrar"),
        ("Parking", "parking"),
        ("Tutoring", "learning"),
        ("Financial aid", "finaid"),
        ("Counseling", "counseling"),
        ("IT help", "it"),
        ("Housing", "housing"),
    ]

    // Home widgets: (key, name, description, on by default)
    static let widgetList: [(key: String, label: String, sub: String, onByDefault: Bool)] = [
        ("next", "Next class", "Your upcoming class", true),
        ("cal", "This week", "A calendar of your classes", true),
        ("due", "Due soon", "Tasks from your planner", true),
        ("links", "Quick links", "Canvas, Banweb, and more", true),
        ("help", "Get help shortcuts", "Common needs, one tap away", false),
        ("saved", "Saved people", "Contacts you starred", true),
        ("org", "Student org of the day", "Discover a new organization", false),
        ("places", "People & places", "Shortcuts to the directory and map", false),
    ]

    func widgetOn(_ key: String) -> Bool {
        if let chosen = widgets[key] { return chosen }
        return LSStore.widgetList.first { $0.key == key }?.onByDefault ?? false
    }

    func toggleWidget(_ key: String) {
        widgets[key] = !widgetOn(key)
    }

    // MARK: Tasks

    var dueSoon: [LSTask] {
        Array(tasks.filter { !$0.done }.prefix(2))
    }

    /// The courses offered in the Add task form: the student's classes, then "Other".
    var courseOptions: [String] {
        var options: [String] = []
        for row in classRows where !options.contains(row.code) {
            options.append(row.code)
        }
        options.append("Other")
        return options
    }

    func addTask(type: String, course: String) {
        tasks.append(LSTask(type: type, course: course, due: "No date", done: false))
    }

    /// Check or uncheck a task. Checking it shows a "Marked done" message with Undo for a few seconds.
    func toggleTask(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].done.toggle()
        guard tasks[index].done else {
            toast = nil
            return
        }
        let message = LSToast(text: "Marked done", taskID: id)
        toast = message
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            guard let self = self else { return }
            if self.toast?.token == message.token {
                self.toast = nil
            }
        }
    }

    func undoToast() {
        if let current = toast {
            toggleTask(current.taskID)
        }
    }

    // MARK: Search

    static let tools: [LSTool] = [
        LSTool(id: "dir", label: "Directory", sub: "Faculty and staff", icon: "person.2", keywords: "directory people contacts faculty staff professor", action: .directory),
        LSTool(id: "help", label: "Get help", sub: "Find the right office", icon: "questionmark.circle", keywords: "who to ask help office problem", action: .getHelp),
        LSTool(id: "map", label: "Campus map", sub: "Buildings and floors", icon: "map", keywords: "map building library meem fisher union floor directions room", action: .map),
        LSTool(id: "links", label: "Common links", sub: "Canvas, Banweb, more", icon: "link", keywords: "links canvas banweb mymichigantech calendar", action: .links),
        LSTool(id: "depts", label: "Departments", sub: "People by department", icon: "square.grid.2x2", keywords: "departments college office", action: .departments),
        LSTool(id: "tutor", label: "Tutoring", sub: "Learning centers by subject", icon: "graduationcap", keywords: "tutor tutoring learning center coaching math physics writing", action: .tutoring),
        LSTool(id: "orgs", label: "Student orgs", sub: "Clubs and organizations", icon: "flag", keywords: "student organizations clubs greek sports", action: .orgs),
        LSTool(id: "tasks", label: "Task planner", sub: "Assignments and exams", icon: "checklist", keywords: "planner tasks homework assignment exam", action: .tasks),
        LSTool(id: "classes", label: "My classes", sub: "Your class schedule", icon: "clock", keywords: "classes schedule class times", action: .classes),
        LSTool(id: "sos", label: "Emergency numbers", sub: "911 and campus lines", icon: "phone", keywords: "emergency 911 988 police safety counseling", action: .emergency),
    ]

    private var q: String { clean(query) }

    var searchIsIdle: Bool { q.isEmpty }

    var lingoHits: [LSLingo] {
        guard !q.isEmpty else { return [] }
        return data.lingo.filter { ($0.term + " " + $0.meaning).lowercased().contains(q) }
    }

    var officeHits: [LSOffice] {
        guard !q.isEmpty else { return [] }
        return Array(data.offices.filter { $0.hay.contains(q) }.prefix(4))
    }

    var centerHits: [LSCenter] {
        guard !q.isEmpty else { return [] }
        return Array(data.centers.filter { $0.hay.contains(q) }.prefix(4))
    }

    var peopleHits: [LSPerson] {
        guard !q.isEmpty else { return [] }
        return Array(data.people.filter { $0.hay.contains(q) }.prefix(5))
    }

    var orgHits: [LSOrg] {
        guard !q.isEmpty else { return [] }
        return Array(data.orgs.filter { $0.hay.contains(q) }.prefix(4))
    }

    var toolHits: [LSTool] {
        guard !q.isEmpty else { return [] }
        return LSStore.tools.filter { ($0.label + " " + $0.keywords).lowercased().contains(q) }
    }
}
