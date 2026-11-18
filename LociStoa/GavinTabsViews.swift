import SwiftUI

// MARK: - Shared Chip Component (Matches chip() in Main.dc.html)
struct GavinChipButton: View {
    let label: String
    let isSelected: Bool
    let theme: LociTheme
    var dotColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let dotColor {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 10, height: 10)
                }
                Text(label)
                    .font(LociFont.sans(14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : theme.ink)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(isSelected ? theme.ink : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? theme.ink : theme.strong, lineWidth: 1.5)
            )
        }
        .buttonStyle(LociPressButtonStyle())
    }
}

// MARK: - 1. HOME TAB VIEW
struct GavinHomeTabView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    
    private let helpShortcuts: [(label: String, officeId: String)] = [
        ("Transcript", "registrar"),
        ("Parking", "parking"),
        ("Tutoring", "learning"),
        ("Financial aid", "finaid"),
        ("Counseling", "counseling"),
        ("IT help", "it"),
        ("Housing", "housing")
    ]
    
    private let commonLinks: [(title: String, url: String)] = [
        ("MyMichiganTech", "https://mymichigantech.mtu.edu/"),
        ("Canvas", "https://mtu.instructure.com/"),
        ("Banweb", "https://www.banweb.mtu.edu/"),
        ("Academic Calendar", "https://www.mtu.edu/registrar/students/calendars/")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("LociStoa")
                    .font(LociFont.display(15, weight: .bold))
                    .tracking(0.3)
                    .foregroundColor(theme.word)
                
                Text("Dashboard")
                    .font(LociFont.display(36, weight: .heavy))
                    .tracking(-0.7)
                    .foregroundColor(theme.ink)
                
                Text(store.todayText)
                    .font(LociFont.sans(15, weight: .semibold))
                    .foregroundColor(theme.sub)
                    .padding(.top, 4)
            }
            
            // 1. Next Class Hero Card (wNext)
            if store.isWidgetEnabled("next") {
                nextClassSection
            }
            
            // 2. This Week Calendar Card (wCal)
            if store.isWidgetEnabled("cal") {
                thisWeekSection
            }
            
            // 3. Due Soon Card (wDue)
            if store.isWidgetEnabled("due") {
                dueSoonSection
            }
            
            // 4. Campus Tools (Original LociStoa Dashboard Features in Gavin UI)
            if store.isWidgetEnabled("tools") {
                campusToolsSection
            }
            
            // 5. Quick Links (wLinks)
            if store.isWidgetEnabled("links") {
                quickLinksSection
            }
            
            // 5. Get Help With (wHelp)
            if store.isWidgetEnabled("help") {
                getHelpShortcutsSection
            }
            
            // 6. Saved People (hasFavs)
            if store.isWidgetEnabled("saved") && !store.savedContacts.isEmpty {
                savedPeopleSection
            }
            
            // 7. Student Org of the Day (wOrg)
            if store.isWidgetEnabled("org"), let spot = store.orgOfTheDay {
                orgOfTheDaySection(spot: spot)
            }
            
            // 8. People & Places (wPlaces)
            if store.isWidgetEnabled("places") {
                peopleAndPlacesSection
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: Next Class Hero Card
    private var nextClassSection: some View {
        ZStack(alignment: .topTrailing) {
            LociHeroWavesDecoration()
                .offset(x: 60, y: -40)
            
            VStack(alignment: .leading, spacing: 14) {
                if let next = store.nextClassInfo {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(next.label.uppercased())
                            .font(LociFont.sans(12, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.h1)
                        
                        Text(next.code)
                            .font(LociFont.display(32, weight: .heavy))
                            .tracking(-0.6)
                            .foregroundColor(.white)
                        
                        Text(next.line)
                            .font(LociFont.sans(16, weight: .medium).monospacedDigit())
                            .foregroundColor(theme.h2)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MY CLASSES")
                            .font(LociFont.sans(12, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.h1)
                        
                        Text(store.classes.isEmpty ? "Add your classes" : "No classes coming up")
                            .font(LociFont.display(28, weight: .heavy))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                        
                        Text(store.classes.isEmpty ? "Build your schedule and your next class shows up here." : "Nothing on your schedule this week.")
                            .font(LociFont.sans(15, weight: .regular))
                            .foregroundColor(theme.h2)
                    }
                }
                
                Button(action: {
                    store.go(.planner, planMode: .times)
                }) {
                    HStack(spacing: 6) {
                        Text("My classes")
                            .font(LociFont.sans(14, weight: .bold))
                        LociIcon(kind: .chevronRight, size: 16, lineWidth: 2.2, color: theme.ink)
                    }
                    .foregroundColor(theme.ink)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(LociPressButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(theme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
    
    // MARK: This Week Calendar Card
    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This week")
                    .font(LociFont.display(19, weight: .bold))
                    .foregroundColor(theme.ink)
                Spacer()
                Button(action: {
                    store.go(.planner, planMode: .times)
                }) {
                    Text("Edit classes")
                        .font(LociFont.sans(14, weight: .semibold))
                        .underline()
                        .foregroundColor(theme.ink)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 6) {
                ForEach(store.weekCalendarDays, id: \.index) { day in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.16)) {
                            store.calDay = day.index
                        }
                    }) {
                        VStack(spacing: 1) {
                            Text(day.top)
                                .font(LociFont.sans(11.5, weight: .bold))
                            Text("\(day.num)")
                                .font(LociFont.display(20, weight: .heavy).monospacedDigit())
                            Text(day.dots)
                                .font(LociFont.sans(14, weight: .bold))
                                .tracking(1)
                                .frame(height: 10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .foregroundColor(day.on ? .white : theme.ink)
                        .background(day.on ? theme.ink : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(day.on ? theme.ink : theme.strong, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            let dayClasses = store.selectedCalDayClasses
            if !dayClasses.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(dayClasses.enumerated()), id: \.element.item.id) { _, cls in
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(theme.rule)
                                .frame(height: 1)
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cls.code)
                                        .font(LociFont.sans(15, weight: .bold))
                                        .foregroundColor(theme.ink)
                                    Text(cls.name)
                                        .font(LociFont.sans(12.5, weight: .regular))
                                        .foregroundColor(theme.sub)
                                }
                                Spacer()
                                Text(cls.time)
                                    .font(LociFont.sans(13.5, weight: .semibold).monospacedDigit())
                                    .foregroundColor(theme.ink)
                            }
                            .frame(minHeight: 52)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(theme.rule)
                        .frame(height: 1)
                        .padding(.bottom, 10)
                    Text(store.calEmptyText)
                        .font(LociFont.sans(14, weight: .regular))
                        .foregroundColor(theme.sub)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
    }
    
    // MARK: Due Soon Card
    private var dueSoonSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Due soon")
                    .font(LociFont.display(19, weight: .bold))
                    .foregroundColor(theme.ink)
                Spacer()
                Button(action: {
                    store.go(.planner, planMode: .tasks)
                }) {
                    Text("Open planner")
                        .font(LociFont.sans(14, weight: .semibold))
                        .underline()
                        .foregroundColor(theme.ink)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            let due = store.dueSoonTasks
            if !due.isEmpty {
                ForEach(due) { t in
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(theme.rule)
                            .frame(height: 1)
                        HStack(spacing: 12) {
                            Button(action: {
                                store.toggleTask(t.id)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(t.done ? theme.accent : Color.clear)
                                        .frame(width: 24, height: 24)
                                    Circle()
                                        .stroke(t.done ? theme.accent : theme.check, lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    if t.done {
                                        LociIcon(kind: .check, size: 14, lineWidth: 3, color: .white)
                                    }
                                }
                                .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, -8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.type)
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text(t.description.isEmpty ? t.course : "\(t.course) · \(t.description)")
                                    .font(LociFont.sans(13, weight: .regular))
                                    .foregroundColor(theme.sub)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(t.due)
                                .font(LociFont.sans(12, weight: .bold))
                                .foregroundColor(theme.ink)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(theme.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .frame(minHeight: 56)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(theme.rule)
                        .frame(height: 1)
                        .padding(.bottom, 10)
                    Text("You're all caught up")
                        .font(LociFont.sans(15, weight: .semibold))
                        .foregroundColor(theme.ink)
                    Text("New tasks you add in the planner show up here.")
                        .font(LociFont.sans(13, weight: .regular))
                        .foregroundColor(theme.sub)
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
    }
    
    // MARK: Campus Tools Section (All 8 Original LociStoa Dashboard Features in Gavin UI)
    private var campusToolsSection: some View {
        let dashboardTools: [(title: String, sub: String, icon: LociIconKind, primary: Bool, action: () -> Void)] = [
            ("Live Interactive Map", "GPS, Skywalks & Floor Plans", .map, true, {
                store.activeDashboardSheet = .map
            }),
            ("Directory Contacts", "Server Sync & Office Locator", .people, false, {
                store.activeDashboardSheet = .contacts
            }),
            ("Course Schedule", "Regular & Friday Bell Times", .clock, false, {
                store.activeDashboardSheet = .schedule
            }),
            ("Task Flow Planner", "Assignments & Due Dates", .planner, false, {
                store.activeDashboardSheet = .planner
            }),
            ("Career Fair", "Attending Companies & Booths", .briefcase, false, {
                store.activeDashboardSheet = .careerFair
            }),
            ("Common Links", "MyMichiganTech, Canvas, Banweb", .link, false, {
                store.activeDashboardSheet = .links
            }),
            ("Ask LociStoa", "Campus AI Assistant", .chat, false, {
                store.activeDashboardSheet = .chatbot
            }),
            ("Nomenclature", "Campus Lingo & Acronyms", .book, false, {
                store.activeDashboardSheet = .nomenclature
            })
        ]
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Campus tools")
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            // Featured Live Interactive Map Banner Button
            Button(action: {
                store.activeDashboardSheet = .map
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 44, height: 44)
                        LociIcon(kind: .map, size: 22, lineWidth: 2.2, color: .white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Live Interactive Map")
                            .font(LociFont.sans(16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Heated winter skywalks, GPS routing & indoor office blueprints")
                            .font(LociFont.sans(12.5))
                            .foregroundColor(theme.h2)
                            .lineLimit(1)
                    }
                    Spacer()
                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: .white)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 68)
                .background(store.effectiveAccentColor)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(LociPressButtonStyle())
            
            // 2-Column Gavin Card Grid for the Original Features
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Array(dashboardTools.dropFirst()), id: \.title) { tool in
                    Button(action: tool.action) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .fill(theme.tint)
                                        .frame(width: 36, height: 36)
                                    LociIcon(kind: tool.icon, size: 18, lineWidth: 2, color: theme.ink)
                                }
                                Spacer()
                                LociIcon(kind: .chevronRight, size: 15, lineWidth: 2.2, color: theme.sub)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tool.title)
                                    .font(LociFont.sans(14.5, weight: .bold))
                                    .foregroundColor(theme.ink)
                                    .lineLimit(1)
                                Text(tool.sub)
                                    .font(LociFont.sans(12))
                                    .foregroundColor(theme.sub)
                                    .lineLimit(1)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
            }
        }
    }
    
    // MARK: Quick Links Section
    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick links")
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(commonLinks, id: \.title) { link in
                    if let url = URL(string: link.url) {
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Text(link.title)
                                    .font(LociFont.sans(14.5, weight: .bold))
                                    .foregroundColor(theme.ink)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                Spacer(minLength: 2)
                                LociIcon(kind: .externalArrow, size: 16, lineWidth: 2.2, color: theme.ink)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Get Help With Section
    private var getHelpShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Get help with")
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(helpShortcuts, id: \.label) { chip in
                        Button(action: {
                            store.go(.people, pv: .help, resetPeopleSelection: true, office: chip.officeId)
                        }) {
                            Text(chip.label)
                                .font(LociFont.sans(14, weight: .semibold))
                                .foregroundColor(theme.ink)
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(theme.strong, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    
    // MARK: Saved People Section
    private var savedPeopleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Saved people")
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.savedContacts) { person in
                        Button(action: {
                            store.openPersonSheet(person)
                        }) {
                            HStack(spacing: 10) {
                                Text(person.initials)
                                    .font(LociFont.sans(13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(theme.ink)
                                    .clipShape(Circle())
                                
                                Text(person.name)
                                    .font(LociFont.sans(14, weight: .semibold))
                                    .foregroundColor(theme.ink)
                            }
                            .padding(.leading, 6)
                            .padding(.trailing, 16)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    
    // MARK: Student Org of the Day Section
    private func orgOfTheDaySection(spot: GavinOrg) -> some View {
        let truncatedDesc: String = {
            if spot.desc.count > 150 {
                let prefix = String(spot.desc.prefix(150))
                if let lastSpace = prefix.lastIndex(of: " ") {
                    return String(prefix[..<lastSpace]) + "…"
                }
                return prefix + "…"
            }
            return spot.desc
        }()
        
        return VStack(alignment: .leading, spacing: 6) {
            Text("STUDENT ORG OF THE DAY")
                .font(LociFont.sans(12, weight: .bold))
                .tracking(0.96)
                .foregroundColor(theme.sub)
            
            Text(spot.name)
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            Text(spot.cat)
                .font(LociFont.sans(13, weight: .semibold))
                .foregroundColor(theme.sub)
            
            Text(truncatedDesc)
                .font(LociFont.sans(14, weight: .regular))
                .foregroundColor(theme.ink)
                .lineSpacing(2)
            
            HStack(spacing: 8) {
                Button(action: {
                    store.go(.people, pv: .orgs, resetPeopleSelection: true, org: spot.i)
                }) {
                    Text("View")
                        .font(LociFont.sans(14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(theme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(LociPressButtonStyle())
                
                Button(action: {
                    store.go(.people, pv: .orgs, resetPeopleSelection: true)
                }) {
                    Text("All orgs")
                        .font(LociFont.sans(14, weight: .bold))
                        .foregroundColor(theme.ink)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(theme.tint)
                        .clipShape(Capsule())
                }
                .buttonStyle(LociPressButtonStyle())
            }
            .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(theme.line, lineWidth: 1)
        )
    }
    
    // MARK: People & Places Section
    private var peopleAndPlacesSection: some View {
        let shortcuts = Array(store.toolShortcuts.prefix(4))
        return VStack(alignment: .leading, spacing: 10) {
            Text("People & places")
                .font(LociFont.display(19, weight: .bold))
                .foregroundColor(theme.ink)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shortcuts) { s in
                        Button(action: s.action) {
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(theme.tint)
                                        .frame(width: 38, height: 38)
                                    LociIcon(kind: s.icon, size: 20, lineWidth: 2, color: theme.ink)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(s.label)
                                        .font(LociFont.sans(15, weight: .bold))
                                        .foregroundColor(theme.ink)
                                    Text(s.sub)
                                        .font(LociFont.sans(12.5, weight: .regular))
                                        .foregroundColor(theme.sub)
                                        .lineLimit(1)
                                }
                            }
                            .padding(14)
                            .frame(width: 146, height: 118, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}

// MARK: - 2. PEOPLE TAB VIEW
struct GavinPeopleTabView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("People")
                .font(LociFont.display(36, weight: .heavy))
                .tracking(-0.7)
                .foregroundColor(theme.ink)
            
            // Emergency Numbers Horizontal Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(LociStoaStore.emergencyNumbers) { num in
                        Button(action: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                store.confirm = num.id
                            }
                        }) {
                            HStack(spacing: 7) {
                                LociIcon(kind: .phone, size: 15, lineWidth: 2.4, color: Color(hex: 0xB3261E))
                                Text(num.chip)
                                    .font(LociFont.sans(14, weight: .semibold))
                                    .foregroundColor(theme.ink)
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 14)
                            .frame(height: 44)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(theme.line, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            
            // People Sub-navigation Chips (Directory, Get help, Departments, Student orgs)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GavinPeopleSubView.allCases) { seg in
                        GavinChipButton(
                            label: seg.label,
                            isSelected: store.pv == seg,
                            theme: theme
                        ) {
                            store.go(.people, pv: seg, resetPeopleSelection: true)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            
            // Active Sub-view Content
            switch store.pv {
            case .dir:
                directorySubView
            case .depts:
                if store.dept != nil {
                    departmentDetailSubView
                } else {
                    departmentListSubView
                }
            case .help:
                if store.office != nil {
                    helpOfficeDetailSubView
                } else {
                    helpOfficeListSubView
                }
            case .orgs:
                if store.org != nil {
                    orgDetailSubView
                } else {
                    orgListSubView
                }
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: Directory Sub-view
    private var directorySubView: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Search Bar
            HStack(spacing: 10) {
                LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                TextField("Name, title, or department", text: $store.dirQuery)
                    .font(LociFont.sans(16))
                    .foregroundColor(theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.strong, lineWidth: 1.5)
            )
            
            // Role Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["All", "Faculty", "Staff"], id: \.self) { f in
                        GavinChipButton(
                            label: f,
                            isSelected: store.filter == f,
                            theme: theme
                        ) {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                store.filter = f
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            
            // Count Label + Server Sync / Full Directory View Actions
            HStack {
                Text(store.dirCountText)
                    .font(LociFont.sans(13, weight: .semibold))
                    .foregroundColor(theme.sub)
                Spacer()
                Button(action: {
                    Task {
                        store.triggerDirectoryLoadingShimmer()
                        await store.directoryVM.fetchContacts()
                    }
                }) {
                    HStack(spacing: 5) {
                        LociIcon(kind: .refresh, size: 13, lineWidth: 2.2, color: theme.accent)
                        Text("Sync Server")
                            .font(LociFont.sans(12.5, weight: .bold))
                            .foregroundColor(theme.ink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(theme.line, lineWidth: 1))
                }
                .buttonStyle(LociPressButtonStyle())
            }
            
            if store.dirLoading {
                // Shimmer Skeleton Card
                VStack(spacing: 0) {
                    let widths: [(CGFloat, CGFloat)] = [(0.60, 0.82), (0.48, 0.74), (0.66, 0.58), (0.54, 0.78)]
                    ForEach(0..<4, id: \.self) { idx in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 12) {
                                LociShimmerBox(theme: theme, width: 44, height: 44, cornerRadius: 22)
                                GeometryReader { geo in
                                    VStack(alignment: .leading, spacing: 8) {
                                        LociShimmerBox(theme: theme, width: geo.size.width * widths[idx].0, height: 14, cornerRadius: 7)
                                        LociShimmerBox(theme: theme, width: geo.size.width * widths[idx].1, height: 12, cornerRadius: 6)
                                    }
                                    .frame(maxHeight: .infinity, alignment: .center)
                                }
                            }
                            .frame(height: 68)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else if !store.visibleDirectoryPeople.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(store.visibleDirectoryPeople.enumerated()), id: \.element.id) { idx, c in
                        VStack(alignment: .leading, spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 12) {
                                Button(action: {
                                    store.openPersonSheet(c)
                                }) {
                                    HStack(spacing: 12) {
                                        Text(c.initials)
                                            .font(LociFont.sans(14, weight: .bold))
                                            .foregroundColor(theme.ink)
                                            .frame(width: 44, height: 44)
                                            .background(theme.tint)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(c.name)
                                                .font(LociFont.sans(15, weight: .bold))
                                                .foregroundColor(theme.ink)
                                            Text("\(c.role) · \(c.dept)")
                                                .font(LociFont.sans(13, weight: .regular))
                                                .foregroundColor(theme.sub)
                                                .lineLimit(1)
                                            if c.office != "Not listed" {
                                                Text(c.office)
                                                    .font(LociFont.sans(12, weight: .semibold))
                                                    .foregroundColor(theme.accent)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if c.office != "Not listed" {
                                    Button(action: {
                                        store.locatePersonOnInteractiveMap(c)
                                    }) {
                                        HStack(spacing: 4) {
                                            LociIcon(kind: .mapPin, size: 13, lineWidth: 2, color: theme.accent)
                                            Text("Map")
                                                .font(LociFont.sans(12, weight: .bold))
                                                .foregroundColor(theme.ink)
                                        }
                                        .padding(.horizontal, 10)
                                        .frame(height: 32)
                                        .background(theme.tint)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(LociPressButtonStyle())
                                }
                                
                                Button(action: {
                                    store.openPersonSheet(c)
                                }) {
                                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 8)
                            .frame(minHeight: 68)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                // Empty state
                VStack(alignment: .leading, spacing: 6) {
                    Text("No one matches that search")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Check the spelling, or try a department or job title.")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                    Button(action: {
                        store.dirQuery = ""
                        store.filter = "All"
                    }) {
                        Text("Clear search")
                            .font(LociFont.sans(14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .frame(height: 44)
                            .background(theme.accent)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(LociPressButtonStyle())
                    .padding(.top, 6)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: Departments List Sub-view
    private var departmentListSubView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                TextField("Department or office name", text: $store.deptQuery)
                    .font(LociFont.sans(16))
                    .foregroundColor(theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.strong, lineWidth: 1.5)
            )
            
            Text(store.deptCountText)
                .font(LociFont.sans(13, weight: .semibold))
                .foregroundColor(theme.sub)
            
            let list = store.visibleDepartments
            if !list.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(list.enumerated()), id: \.element.id) { idx, d in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    store.dept = d.name
                                }
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(d.name)
                                            .font(LociFont.sans(15, weight: .bold))
                                            .foregroundColor(theme.ink)
                                            .multilineTextAlignment(.leading)
                                        Text(d.countText)
                                            .font(LociFont.sans(13))
                                            .foregroundColor(theme.sub)
                                    }
                                    Spacer()
                                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                }
                                .padding(.vertical, 6)
                                .frame(minHeight: 64)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No department matches")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Try a shorter name, like \"business\" or \"library\".")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: Department Detail Page Sub-view
    private var departmentDetailSubView: some View {
        let curDeptName = store.dept ?? ""
        let meta = store.deptMeta[curDeptName] ?? ["", ""]
        let cat = meta.first ?? ""
        let reports = meta.count > 1 ? meta[1] : ""
        let grouped = store.currentDeptPeopleGrouped
        
        return VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    store.dept = nil
                }
            }) {
                HStack(spacing: 4) {
                    LociIcon(kind: .chevronLeft, size: 18, lineWidth: 2.4, color: theme.ink)
                    Text("All departments")
                        .font(LociFont.sans(14, weight: .bold))
                        .foregroundColor(theme.ink)
                }
                .frame(height: 44)
            }
            .buttonStyle(.plain)
            
            if !cat.isEmpty {
                Text(cat.uppercased())
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
            }
            
            Text(curDeptName)
                .font(LociFont.display(24, weight: .heavy))
                .foregroundColor(theme.ink)
            
            if !reports.isEmpty {
                HStack(spacing: 4) {
                    Text("Reports up to:")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                    Text(reports)
                        .font(LociFont.sans(14, weight: .bold))
                        .foregroundColor(theme.ink)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(grouped.enumerated()), id: \.element.person.id) { _, item in
                    VStack(alignment: .leading, spacing: 0) {
                        if item.showHead {
                            Text(item.head.uppercased())
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                                .padding(.top, 14)
                                .padding(.bottom, 4)
                        }
                        if !item.isFirstInGroup {
                            Rectangle().fill(theme.rule).frame(height: 1)
                        }
                        Button(action: {
                            store.openPersonSheet(item.person)
                        }) {
                            HStack(spacing: 12) {
                                Text(item.person.initials)
                                    .font(LociFont.sans(14, weight: .bold))
                                    .foregroundColor(theme.ink)
                                    .frame(width: 44, height: 44)
                                    .background(theme.tint)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.person.name)
                                        .font(LociFont.sans(15, weight: .bold))
                                        .foregroundColor(theme.ink)
                                    Text(item.person.role)
                                        .font(LociFont.sans(13))
                                        .foregroundColor(theme.sub)
                                }
                                Spacer()
                                LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                            }
                            .padding(.vertical, 6)
                            .frame(minHeight: 64)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 6)
            .padding(.horizontal, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
        }
    }
    
    // MARK: Get Help List Sub-view
    private var helpOfficeListSubView: some View {
        let helpItems = store.filteredHelpOffices
        return VStack(alignment: .leading, spacing: 14) {
            Text("Tell us what you need and we'll point you to the right office.")
                .font(LociFont.sans(15))
                .foregroundColor(theme.sub)
            
            HStack(spacing: 10) {
                LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                TextField("Try \"transcript\" or \"parking\"", text: $store.helpQuery)
                    .font(LociFont.sans(16))
                    .foregroundColor(theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.strong, lineWidth: 1.5)
            )
            
            if !helpItems.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(helpItems, id: \.office.id) { item in
                        VStack(alignment: .leading, spacing: 0) {
                            if item.showHead {
                                Text(item.office.category.uppercased())
                                    .font(LociFont.sans(12, weight: .bold))
                                    .tracking(0.96)
                                    .foregroundColor(theme.sub)
                                    .padding(.top, 14)
                                    .padding(.bottom, 4)
                            } else {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    store.office = item.office.id
                                }
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.office.goHereFor)
                                            .font(LociFont.sans(15, weight: .bold))
                                            .foregroundColor(theme.ink)
                                            .multilineTextAlignment(.leading)
                                        Text(item.office.name)
                                            .font(LociFont.sans(13))
                                            .foregroundColor(theme.sub)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                }
                                .padding(.vertical, 6)
                                .frame(minHeight: 64)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 6)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No office matches that")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Try a different word, or ask the Dean of Students office. They can point you anywhere.")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: Get Help Office Detail Sub-view
    private var helpOfficeDetailSubView: some View {
        guard let curOffice = store.currentOffice else { return AnyView(EmptyView()) }
        let rows: [(label: String, value: String)] = [
            ("Location", curOffice.location ?? ""),
            ("Hours", curOffice.hours ?? ""),
            ("Email", curOffice.email ?? ""),
            ("Main line", curOffice.phone ?? "")
        ].filter { !$0.1.isEmpty }
        let firstDept = curOffice.departments?.first
        
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.office = nil
                    }
                }) {
                    HStack(spacing: 4) {
                        LociIcon(kind: .chevronLeft, size: 18, lineWidth: 2.4, color: theme.ink)
                        Text("All topics")
                            .font(LociFont.sans(14, weight: .bold))
                            .foregroundColor(theme.ink)
                    }
                    .frame(height: 44)
                }
                .buttonStyle(.plain)
                
                Text(curOffice.category.uppercased())
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                Text(curOffice.name)
                    .font(LociFont.display(24, weight: .heavy))
                    .foregroundColor(theme.ink)
                
                Text(curOffice.goHereFor)
                    .font(LociFont.sans(15))
                    .foregroundColor(theme.sub)
                
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(alignment: .center, spacing: 16) {
                                Text(row.label)
                                    .font(LociFont.sans(13.5))
                                    .foregroundColor(theme.sub)
                                Spacer()
                                Text(row.value)
                                    .font(LociFont.sans(14.5, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.vertical, 8)
                            .frame(minHeight: 54)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
                .padding(.top, 4)
                
                if let note = curOffice.note, !note.isEmpty {
                    Text(note)
                        .font(LociFont.sans(13.5))
                        .foregroundColor(theme.sub)
                }
                
                if let website = curOffice.website, let url = URL(string: website) {
                    Link(destination: url) {
                        HStack {
                            Text("Open website")
                                .font(LociFont.sans(15, weight: .bold))
                                .foregroundColor(theme.ink)
                            Spacer()
                            LociIcon(kind: .externalArrow, size: 18, lineWidth: 2.2, color: theme.ink)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 52)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                
                if let deptName = firstDept, !deptName.isEmpty {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            store.pv = .depts
                            store.dept = deptName
                            store.office = nil
                        }
                    }) {
                        Text("See people in this office")
                            .font(LociFont.sans(15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
            }
        )
    }
    
    // MARK: Student Orgs List Sub-view
    private var orgListSubView: some View {
        let allCats = ["All"] + store.orgCatNames
        let list = store.visibleOrgs
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                TextField("Organization name", text: $store.orgQuery)
                    .font(LociFont.sans(16))
                    .foregroundColor(theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.strong, lineWidth: 1.5)
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allCats, id: \.self) { cat in
                        GavinChipButton(
                            label: cat,
                            isSelected: store.orgCat == cat,
                            theme: theme
                        ) {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                store.orgCat = cat
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            
            Text(store.orgCountText)
                .font(LociFont.sans(13, weight: .semibold))
                .foregroundColor(theme.sub)
            
            if !list.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(list.enumerated()), id: \.element.id) { idx, o in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    store.org = o.i
                                }
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(o.name)
                                            .font(LociFont.sans(15, weight: .bold))
                                            .foregroundColor(theme.ink)
                                            .multilineTextAlignment(.leading)
                                        Text(o.cat)
                                            .font(LociFont.sans(13))
                                            .foregroundColor(theme.sub)
                                    }
                                    Spacer()
                                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                }
                                .padding(.vertical, 6)
                                .frame(minHeight: 64)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No organization matches")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Try a shorter name or a different category.")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: Student Org Detail Sub-view
    private var orgDetailSubView: some View {
        guard let curOrg = store.currentOrg else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.org = nil
                    }
                }) {
                    HStack(spacing: 4) {
                        LociIcon(kind: .chevronLeft, size: 18, lineWidth: 2.4, color: theme.ink)
                        Text("All organizations")
                            .font(LociFont.sans(14, weight: .bold))
                            .foregroundColor(theme.ink)
                    }
                    .frame(height: 44)
                }
                .buttonStyle(.plain)
                
                Text(curOrg.cat.uppercased())
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                Text(curOrg.name)
                    .font(LociFont.display(24, weight: .heavy))
                    .foregroundColor(theme.ink)
                
                Text(curOrg.desc)
                    .font(LociFont.sans(15))
                    .foregroundColor(theme.ink)
                    .lineSpacing(3)
                
                if !curOrg.email.isEmpty {
                    HStack(spacing: 16) {
                        Text("Email")
                            .font(LociFont.sans(13.5))
                            .foregroundColor(theme.sub)
                        Spacer()
                        Text(curOrg.email)
                            .font(LociFont.sans(14.5, weight: .semibold))
                            .foregroundColor(theme.ink)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 54)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(theme.line, lineWidth: 1)
                    )
                    .padding(.top, 4)
                }
                
                if !curOrg.site.isEmpty, let url = URL(string: curOrg.site) {
                    Link(destination: url) {
                        HStack {
                            Text("Open website")
                                .font(LociFont.sans(15, weight: .bold))
                                .foregroundColor(theme.ink)
                            Spacer()
                            LociIcon(kind: .externalArrow, size: 18, lineWidth: 2.2, color: theme.ink)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 52)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        )
    }
}

// MARK: - 3. MAP TAB VIEW (Supports both Original Live Interactive MapKit Map & Gavin Stylized Campus Diagram)
struct GavinMapTabView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    private let layers = ["All", "Academic", "Services", "Housing", "Athletics"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header + Full Screen Button
            HStack(alignment: .center) {
                Text("Map")
                    .font(LociFont.display(36, weight: .heavy))
                    .tracking(-0.7)
                    .foregroundColor(theme.ink)
                Spacer()
                Button(action: {
                    store.activeDashboardSheet = .map
                }) {
                    HStack(spacing: 6) {
                        LociIcon(kind: .externalArrow, size: 14, lineWidth: 2.2, color: theme.ink)
                        Text("Full Screen")
                            .font(LociFont.sans(13, weight: .bold))
                            .foregroundColor(theme.ink)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(theme.line, lineWidth: 1))
                }
                .buttonStyle(LociPressButtonStyle())
            }
            
            // Map Mode Segmented Control (Live Interactive Map | Campus Diagram)
            HStack(spacing: 0) {
                ForEach(GavinMapViewMode.allCases) { mode in
                    let isSelected = (store.mapMode == mode)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            store.mapMode = mode
                        }
                    }) {
                        Text(mode.label)
                            .font(LociFont.sans(13.5, weight: isSelected ? .bold : .semibold))
                            .foregroundColor(theme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(isSelected ? Color.white : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(
                                color: isSelected ? Color(hex: 0x2B1F52).opacity(0.18) : .clear,
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(theme.tint)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            if store.mapMode == .interactive {
                // Original LociStoa Live Interactive MapKit + Winter Skywalk + Indoor Blueprint View
                MapView(
                    isEmbeddedInTab: true,
                    theme: theme
                )
            } else {
                diagramMapContent
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .sheet(isPresented: $store.showInteractiveIndoorSheet) {
            let matchedBuilding = MTUCampusData.buildings.first {
                $0.id == store.building || ($0.id == "library" && store.building == "lib")
            } ?? MTUCampusData.buildings[0]
            MTUIndoorMapView(
                building: matchedBuilding,
                initialFloorCode: store.floor,
                onClose: { store.showInteractiveIndoorSheet = false }
            )
        }
    }
    
    private var diagramMapContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Layer Filter Chips with Colored Dots
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(layers, id: \.self) { l in
                        GavinChipButton(
                            label: l,
                            isSelected: store.layer == l,
                            theme: theme,
                            dotColor: GavinMapBuilding.layerColor(for: l)
                        ) {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                store.layer = l
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            
            // 340pt Tall Scrollable Campus Map Container (1000x710 Canvas)
            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // Base Vector Map Artwork (Matches SVG in Main.dc.html lines 393-408)
                        GavinCampusVectorMapCanvas()
                            .frame(width: 1000, height: 710)
                        
                        // Invisible Center Anchor at (470, 330)
                        Color.clear
                            .frame(width: 1, height: 1)
                            .position(x: 470, y: 330)
                            .id("map-center-home")
                        
                        // 23 Interactive Building Buttons
                        ForEach(LociStoaStore.mapBuildings) { b in
                            let isSelected = (store.building == b.id)
                            let inLayer = (store.layer == "All") || (store.layer == b.layer)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    store.building = b.id
                                    store.floor = "1F"
                                }
                            }) {
                                Text(b.short)
                                    .font(LociFont.sans(11.5, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(-1)
                                    .padding(.horizontal, 4)
                                    .frame(width: b.w, height: b.h)
                                    .background(b.bgColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        Group {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(Color.white, lineWidth: 3)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                                                            .stroke(Color(hex: 0x111111), lineWidth: 3)
                                                            .padding(-3)
                                                    )
                                            }
                                        }
                                    )
                                    .shadow(color: .black.opacity(isSelected ? 0 : 0.3), radius: 1, x: 0, y: 1)
                                    .opacity(inLayer ? 1.0 : 0.25)
                            }
                            .buttonStyle(LociPressButtonStyle())
                            .position(x: b.x, y: b.y)
                            .id("map-b-\(b.id)")
                        }
                    }
                    .frame(width: 1000, height: 710)
                }
                .frame(height: 340)
                .background(Color(hex: 0xEEF2EC))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(theme.strong, lineWidth: 1)
                )
                .onAppear {
                    if let b = store.building {
                        proxy.scrollTo("map-b-\(b)", anchor: .center)
                    } else {
                        proxy.scrollTo("map-center-home", anchor: .center)
                    }
                }
                .onChange(of: store.building) { _, newB in
                    if let newB {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("map-b-\(newB)", anchor: .center)
                        }
                    }
                }
            }
            
            Text("Drag the map to look around. Simplified layout, not to scale.")
                .font(LociFont.sans(13))
                .foregroundColor(theme.sub)
            
            // Building Details Card below Map
            if let curB = store.selectedMapBuilding {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(curB.name)
                            .font(LociFont.display(20, weight: .bold))
                            .foregroundColor(theme.ink)
                        Text(curB.layer)
                            .font(LociFont.sans(13.5, weight: .semibold))
                            .foregroundColor(theme.sub)
                        Text(curB.inside)
                            .font(LociFont.sans(14))
                            .foregroundColor(theme.ink)
                    }
                    
                    // Floor Selector Buttons (1F, 2F, 3F)
                    HStack(spacing: 8) {
                        ForEach(["1F", "2F", "3F"], id: \.self) { f in
                            let on = (store.floor == f)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.16)) {
                                    store.floor = f
                                }
                            }) {
                                Text(f)
                                    .font(LociFont.sans(15, weight: .bold))
                                    .foregroundColor(on ? .white : theme.ink)
                                    .frame(width: 64, height: 44)
                                    .background(on ? theme.ink : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(on ? theme.ink : theme.strong, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Dashed Floor Plan Box (tappable to open interactive floor plan)
                    Button(action: {
                        store.showInteractiveIndoorSheet = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    theme.check,
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                                )
                                .frame(height: 76)
                            
                            VStack(spacing: 3) {
                                Text("Floor plan image for \(store.floor) goes here")
                                    .font(LociFont.sans(13.5, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("Tap to open interactive \(store.floor) blueprint & office routing")
                                    .font(LociFont.sans(12, weight: .bold))
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tap a building")
                        .font(LociFont.sans(15, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("You'll see its floors and what's inside.")
                        .font(LociFont.sans(13.5))
                        .foregroundColor(theme.sub)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Stylized Campus Vector Map Canvas (Exact SVG replication from Main.dc.html)
struct GavinCampusVectorMapCanvas: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, _ in
                // Base fill #EEF2EC
                context.fill(Path(CGRect(x: 0, y: 0, width: 1000, height: 710)), with: .color(Color(hex: 0xEEF2EC)))
                
                // 5 Park Ellipses (#DDEBD6)
                let ellipses: [(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat)] = [
                    (330, 120, 150, 55),
                    (640, 400, 90, 50),
                    (470, 560, 170, 60),
                    (860, 660, 150, 45),
                    (110, 470, 110, 70)
                ]
                for e in ellipses {
                    let rect = CGRect(x: e.cx - e.rx, y: e.cy - e.ry, width: e.rx * 2, height: e.ry * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0xDDEBD6)))
                }
                
                // Keweenaw Waterway Polygon (#A9D3EA)
                // M240 0 L280 48 L475 55 L505 80 L645 125 L675 150 L800 235 L1000 345 L1000 0 Z
                var water = Path()
                water.move(to: CGPoint(x: 240, y: 0))
                water.addLine(to: CGPoint(x: 280, y: 48))
                water.addLine(to: CGPoint(x: 475, y: 55))
                water.addLine(to: CGPoint(x: 505, y: 80))
                water.addLine(to: CGPoint(x: 645, y: 125))
                water.addLine(to: CGPoint(x: 675, y: 150))
                water.addLine(to: CGPoint(x: 800, y: 235))
                water.addLine(to: CGPoint(x: 1000, y: 345))
                water.addLine(to: CGPoint(x: 1000, y: 0))
                water.closeSubpath()
                context.fill(water, with: .color(Color(hex: 0xA9D3EA)))
                
                // US-41 Road Path
                // M0 150 L150 280 Q205 340 260 395 Q330 452 415 465 L600 488 L725 510 L1000 570
                var road = Path()
                road.move(to: CGPoint(x: 0, y: 150))
                road.addLine(to: CGPoint(x: 150, y: 280))
                road.addQuadCurve(to: CGPoint(x: 260, y: 395), control: CGPoint(x: 205, y: 340))
                road.addQuadCurve(to: CGPoint(x: 415, y: 465), control: CGPoint(x: 330, y: 452))
                road.addLine(to: CGPoint(x: 600, y: 488))
                road.addLine(to: CGPoint(x: 725, y: 510))
                road.addLine(to: CGPoint(x: 1000, y: 570))
                
                context.stroke(
                    road,
                    with: .color(Color(hex: 0xC3CAD2)),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round)
                )
                context.stroke(
                    road,
                    with: .color(.white),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
                )
                
                // North Arrow (M40 60 L48 36 L56 60 L48 54 Z)
                var northArrow = Path()
                northArrow.move(to: CGPoint(x: 40, y: 60))
                northArrow.addLine(to: CGPoint(x: 48, y: 36))
                northArrow.addLine(to: CGPoint(x: 56, y: 60))
                northArrow.addLine(to: CGPoint(x: 48, y: 54))
                northArrow.closeSubpath()
                context.fill(northArrow, with: .color(Color(hex: 0x4B5560)))
            }
            
            // Map Labels
            Text("KEWEENAW WATERWAY")
                .font(LociFont.sans(14, weight: .bold))
                .tracking(1.5)
                .foregroundColor(Color(hex: 0x22607F))
                .position(x: 795, y: 75)
            
            Text("US-41 · TOWNSEND DR")
                .font(LociFont.sans(11, weight: .bold))
                .foregroundColor(Color(hex: 0x4B5560))
                .rotationEffect(.degrees(7))
                .position(x: 515, y: 484)
            
            Text("US-41 · COLLEGE AVE")
                .font(LociFont.sans(11, weight: .bold))
                .foregroundColor(Color(hex: 0x4B5560))
                .rotationEffect(.degrees(41))
                .position(x: 105, y: 256)
            
            Text("N")
                .font(LociFont.sans(12, weight: .bold))
                .foregroundColor(Color(hex: 0x4B5560))
                .position(x: 48, y: 71)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 4. PLANNER TAB VIEW
struct GavinPlannerTabView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Planner")
                .font(LociFont.display(36, weight: .heavy))
                .tracking(-0.7)
                .foregroundColor(theme.ink)
            
            // Segmented Control (Tasks | My classes | Periods)
            HStack(spacing: 0) {
                ForEach(GavinPlanMode.allCases) { mode in
                    let isSelected = (store.planMode == mode)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            store.planMode = mode
                        }
                    }) {
                        Text(mode.label)
                            .font(LociFont.sans(14, weight: isSelected ? .bold : .semibold))
                            .foregroundColor(theme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(isSelected ? Color.white : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(
                                color: isSelected ? Color(hex: 0x2B1F52).opacity(0.18) : .clear,
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(theme.tint)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            switch store.planMode {
            case .tasks:
                tasksSection
            case .times:
                classesSection
            case .periods:
                periodsSection
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: Tasks Mode
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !store.tasks.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(store.tasks.enumerated()), id: \.element.id) { idx, t in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 12) {
                                Button(action: {
                                    store.toggleTask(t.id)
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(t.done ? theme.accent : Color.clear)
                                            .frame(width: 24, height: 24)
                                        Circle()
                                            .stroke(t.done ? theme.accent : theme.check, lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        if t.done {
                                            LociIcon(kind: .check, size: 14, lineWidth: 3, color: .white)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, -8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t.type)
                                        .font(LociFont.sans(15, weight: .semibold))
                                        .strikethrough(t.done)
                                        .foregroundColor(theme.ink)
                                    Text(t.course)
                                        .font(LociFont.sans(13, weight: .semibold))
                                        .foregroundColor(theme.sub)
                                    if !t.description.isEmpty {
                                        Text(t.description)
                                            .font(LociFont.sans(12.5))
                                            .foregroundColor(theme.sub)
                                    }
                                }
                                Spacer()
                                Text(t.due)
                                    .font(LociFont.sans(12, weight: .bold))
                                    .foregroundColor(theme.ink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(theme.tint)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                
                                Button(action: {
                                    store.deleteTask(t.id)
                                }) {
                                    LociIcon(kind: .trash, size: 16, lineWidth: 2, color: theme.sub)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Delete task")
                            }
                            .padding(.vertical, 6)
                            .frame(minHeight: 64)
                            .opacity(t.done ? 0.55 : 1.0)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No tasks yet")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Add an assignment, exam, or reading to keep track of it here.")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
            
            Button(action: {
                store.openAddTaskSheet()
            }) {
                HStack(spacing: 8) {
                    LociIcon(kind: .plus, size: 18, lineWidth: 2.6, color: .white)
                    Text("Add task")
                        .font(LociFont.sans(16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(LociPressButtonStyle())
            
            if !store.tasks.isEmpty {
                Button(action: {
                    store.activeDashboardSheet = .planner
                }) {
                    HStack {
                        Text("Open TaskFlow List (Drag to Reorder)")
                            .font(LociFont.sans(14.5, weight: .bold))
                            .foregroundColor(theme.ink)
                        Spacer()
                        LociIcon(kind: .chevronRight, size: 16, lineWidth: 2.2, color: theme.sub)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(theme.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(LociPressButtonStyle())
            }
        }
    }
    
    // MARK: My Classes Mode
    private var classesSection: some View {
        let sorted = store.sortedClasses
        return VStack(alignment: .leading, spacing: 14) {
            if !sorted.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(sorted.enumerated()), id: \.element.item.id) { idx, cls in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cls.code)
                                        .font(LociFont.sans(16, weight: .bold))
                                        .foregroundColor(theme.ink)
                                    Text(cls.name)
                                        .font(LociFont.sans(13))
                                        .foregroundColor(theme.sub)
                                    Text(cls.when)
                                        .font(LociFont.sans(13.5, weight: .semibold).monospacedDigit())
                                        .foregroundColor(theme.ink)
                                        .padding(.top, 2)
                                }
                                Spacer()
                                Button(action: {
                                    store.removeClass(cls.item.id)
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(theme.tint)
                                            .frame(width: 44, height: 44)
                                        LociIcon(kind: .close, size: 16, lineWidth: 2.4, color: theme.ink)
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(cls.code)")
                            }
                            .padding(.vertical, 8)
                            .frame(minHeight: 72)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No classes yet")
                        .font(LociFont.display(19, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text("Add each class once and your next one shows up on the Today screen.")
                        .font(LociFont.sans(14))
                        .foregroundColor(theme.sub)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
            
            Button(action: {
                store.openAddClassSheet()
            }) {
                HStack(spacing: 8) {
                    LociIcon(kind: .plus, size: 18, lineWidth: 2.6, color: .white)
                    Text("Add class")
                        .font(LociFont.sans(16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(LociPressButtonStyle())
        }
    }
    
    // MARK: Periods Mode (Original ScheduleView Regular vs Friday Schedule in Gavin UI)
    private var periodsSection: some View {
        let regularTimes = LociStoaStore.regularPeriodTimes
        let fridayTimes = LociStoaStore.fridayPeriodTimes
        let isFriday = store.fridayScheduleEnabled
        
        return VStack(alignment: .leading, spacing: 14) {
            // Friday Schedule Toggle Card
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Friday Schedule")
                        .font(LociFont.sans(15.5, weight: .bold))
                        .foregroundColor(theme.ink)
                    Text(isFriday ? "Showing Friday period bell times" : "Showing Mon–Thu regular period bell times")
                        .font(LociFont.sans(13))
                        .foregroundColor(theme.sub)
                }
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        store.fridayScheduleEnabled.toggle()
                    }
                }) {
                    ZStack(alignment: isFriday ? .trailing : .leading) {
                        Capsule()
                            .fill(isFriday ? theme.accent : theme.check)
                            .frame(width: 52, height: 32)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)
                            .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
                            .padding(.horizontal, 3)
                    }
                    .frame(width: 56, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
            
            // 8 Period Rows Card
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { index in
                    VStack(spacing: 0) {
                        if index > 0 {
                            Rectangle().fill(theme.rule).frame(height: 1)
                        }
                        HStack(spacing: 14) {
                            Text("\(index + 1)")
                                .font(LociFont.display(16, weight: .heavy))
                                .frame(width: 40, height: 40)
                                .background(theme.tint)
                                .foregroundColor(theme.ink)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Period \(index + 1)")
                                    .font(LociFont.sans(15, weight: .bold))
                                    .foregroundColor(theme.ink)
                                Text(isFriday ? "Friday Schedule" : "Regular Schedule")
                                    .font(LociFont.sans(12.5))
                                    .foregroundColor(theme.sub)
                            }
                            
                            Spacer()
                            
                            Text(isFriday ? fridayTimes[index] : regularTimes[index])
                                .font(LociFont.sans(14.5, weight: .bold).monospacedDigit())
                                .foregroundColor(theme.ink)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(theme.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .padding(.vertical, 8)
                        .frame(minHeight: 62)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
        }
    }
}

// MARK: - 5. MORE TAB VIEW
struct GavinMoreTabView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    
    private let comingSoonWidgets: [(title: String, sub: String)] = [
        ("Dining hall hours", "Needs a live source for hours"),
        ("Campus events", "Needs an events feed"),
        ("Graduation checklist", "For students in their final year")
    ]
    
    private let commonLinks: [(title: String, url: String)] = [
        ("MyMichiganTech", "https://mymichigantech.mtu.edu/"),
        ("Canvas", "https://mtu.instructure.com/"),
        ("Banweb", "https://www.banweb.mtu.edu/"),
        ("Academic Calendar", "https://www.mtu.edu/registrar/students/calendars/")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            Text("More")
                .font(LociFont.display(36, weight: .heavy))
                .tracking(-0.7)
                .foregroundColor(theme.ink)
            
            // 1. Home screen · choose what you see
            VStack(alignment: .leading, spacing: 8) {
                Text("HOME SCREEN · CHOOSE WHAT YOU SEE")
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                VStack(spacing: 0) {
                    ForEach(Array(LociStoaStore.widgetDefinitions.enumerated()), id: \.element.key) { idx, w in
                        let isOn = store.isWidgetEnabled(w.key)
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(w.label)
                                        .font(LociFont.sans(15, weight: .semibold))
                                        .foregroundColor(theme.ink)
                                    Text(w.sub)
                                        .font(LociFont.sans(13))
                                        .foregroundColor(theme.sub)
                                }
                                Spacer()
                                Button(action: {
                                    store.toggleWidget(w.key)
                                }) {
                                    ZStack(alignment: isOn ? .trailing : .leading) {
                                        Capsule()
                                            .fill(isOn ? theme.accent : theme.check)
                                            .frame(width: 52, height: 32)
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 26, height: 26)
                                            .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
                                            .padding(.horizontal, 3)
                                    }
                                    .frame(width: 56, height: 44)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(w.label)
                            }
                            .frame(minHeight: 62)
                        }
                    }
                    
                    ForEach(comingSoonWidgets, id: \.title) { item in
                        VStack(spacing: 0) {
                            Rectangle().fill(theme.rule).frame(height: 1)
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(LociFont.sans(15, weight: .semibold))
                                        .foregroundColor(theme.ink)
                                    Text(item.sub)
                                        .font(LociFont.sans(13))
                                        .foregroundColor(theme.sub)
                                }
                                Spacer()
                                Text("Coming soon")
                                    .font(LociFont.sans(12, weight: .bold))
                                    .foregroundColor(theme.ink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(theme.tint)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .frame(minHeight: 62)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
            
            // 2. Appearance (4 Theme Swatches)
            VStack(alignment: .leading, spacing: 8) {
                Text("APPEARANCE")
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                HStack(spacing: 8) {
                    ForEach(LociTheme.allCases) { t in
                        let isSelected = (store.theme == t)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                store.theme = t
                                store.customPrimaryBgColor = nil
                                store.customSecondaryAccentColor = nil
                            }
                        }) {
                            VStack(spacing: 7) {
                                Circle()
                                    .fill(t.swatch)
                                    .frame(width: 28, height: 28)
                                Text(t.label)
                                    .font(LociFont.sans(13, weight: isSelected ? .bold : .semibold))
                                    .foregroundColor(theme.ink)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(isSelected ? theme.accent : theme.line, lineWidth: 2)
                            )
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                }
            }
            
            // 3. Common links · open in your browser
            VStack(alignment: .leading, spacing: 8) {
                Text("COMMON LINKS · OPEN IN YOUR BROWSER")
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                VStack(spacing: 0) {
                    ForEach(Array(commonLinks.enumerated()), id: \.element.title) { idx, link in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            if let url = URL(string: link.url) {
                                Link(destination: url) {
                                    HStack {
                                        Text(link.title)
                                            .font(LociFont.sans(15, weight: .semibold))
                                            .foregroundColor(theme.ink)
                                        Spacer()
                                        LociIcon(kind: .externalArrow, size: 18, lineWidth: 2.2, color: theme.ink)
                                    }
                                    .frame(height: 56)
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
            
            // 4. Campus Features & Administration (Interactive Original Features)
            VStack(alignment: .leading, spacing: 8) {
                Text("CAMPUS FEATURES & ADMINISTRATION")
                    .font(LociFont.sans(12, weight: .bold))
                    .tracking(0.96)
                    .foregroundColor(theme.sub)
                
                VStack(spacing: 0) {
                    Button(action: {
                        store.activeDashboardSheet = .chatbot
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ask LociStoa")
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("Chatbot for campus questions")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                        }
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Rectangle().fill(theme.rule).frame(height: 1)
                    
                    Button(action: {
                        store.activeDashboardSheet = .careerFair
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Career Fair")
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("Search attending companies & booths")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                        }
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Rectangle().fill(theme.rule).frame(height: 1)
                    
                    Button(action: {
                        store.activeDashboardSheet = .nomenclature
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Campus Nomenclature")
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("MTU lingo & building nicknames")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                        }
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Rectangle().fill(theme.rule).frame(height: 1)
                    
                    Button(action: {
                        store.activeDashboardSheet = .schedule
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Course Period Schedule")
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("Regular & Friday bell schedule")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                        }
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Rectangle().fill(theme.rule).frame(height: 1)
                    
                    Button(action: {
                        store.showingAdminSettings = true
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("IT Administrator Settings")
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                Text("University branding colors & tenant PIN")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                        }
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }
            
            // 5. Sign Out Button (Returns to LoginView)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.22)) {
                    store.isLoggedIn = false
                }
            }) {
                Text("Sign Out")
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(theme.strong, lineWidth: 1.5)
                    )
            }
            .buttonStyle(LociPressButtonStyle())
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
