import SwiftUI

// MARK: - Top-Rounded Corner Shape for Bottom Sheets (border-radius: 28px 28px 0 0)
struct GavinTopRoundedCorners: Shape {
    var radius: CGFloat = 28
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, min(rect.width, rect.height) / 2)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Sheet Overlay Dispatcher (showSheet)
struct GavinSheetOverlay: View {
    @ObservedObject var store: LociStoaStore
    let activeSheet: GavinActiveSheet
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Scrim: rgba(43, 31, 82, 0.5)
            Color(hex: 0x2B1F52, opacity: 0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.22)) {
                        store.sheet = nil
                    }
                }
                .transition(.opacity)
            
            Group {
                switch activeSheet {
                case .emergency:
                    GavinEmergencySheetView(store: store)
                case .contact:
                    GavinContactSheetView(store: store)
                case .add:
                    GavinAddTaskSheetView(store: store)
                case .classSheet:
                    GavinAddClassSheetView(store: store)
                case .search:
                    GavinSearchSheetView(store: store)
                }
            }
            .transition(.move(edge: .bottom))
        }
        .zIndex(20)
    }
}

// MARK: - 1. Emergency Numbers Sheet (showEmergency)
struct GavinEmergencySheetView: View {
    @ObservedObject var store: LociStoaStore
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Drag Handle
            Capsule()
                .fill(theme.strong)
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
            
            // Header
            HStack {
                Text("Emergency numbers")
                    .font(LociFont.display(24, weight: .heavy))
                    .foregroundColor(theme.ink)
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.22)) {
                        store.sheet = nil
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(theme.tint)
                            .frame(width: 44, height: 44)
                        LociIcon(kind: .close, size: 18, lineWidth: 2.4, color: theme.ink)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            
            // Emergency Numbers List
            VStack(spacing: 10) {
                ForEach(LociStoaStore.emergencyNumbers) { n in
                    let rowBg = n.primary ? Color(hex: 0xB3261E) : Color.white
                    let rowBorder = n.primary ? Color(hex: 0xB3261E) : Color(hex: 0xEBC4C0)
                    let rowFg = n.primary ? Color.white : theme.ink
                    let btnBg = n.primary ? Color.white : Color(hex: 0xB3261E)
                    let btnFg = n.primary ? Color(hex: 0xB3261E) : Color.white
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(n.number)
                                .font(LociFont.display(22, weight: .heavy).monospacedDigit())
                                .foregroundColor(rowFg)
                            Text(n.label)
                                .font(LociFont.sans(13.5, weight: .semibold))
                                .foregroundColor(rowFg)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                store.confirm = n.id
                            }
                        }) {
                            HStack(spacing: 8) {
                                LociIcon(kind: .phone, size: 16, lineWidth: 2.2, color: btnFg)
                                Text("Call")
                                    .font(LociFont.sans(15, weight: .bold))
                                    .foregroundColor(btnFg)
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 48)
                            .background(btnBg)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 16)
                    .padding(.trailing, 10)
                    .frame(minHeight: 68)
                    .background(rowBg)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(rowBorder, lineWidth: 1.5)
                    )
                }
            }
            
            Text("Calling is turned off in this prototype. Numbers come from mtu.edu pages, checked November 2026.")
                .font(LociFont.sans(12.5))
                .foregroundColor(theme.sub)
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .background(Color.white)
        .clipShape(GavinTopRoundedCorners(radius: 28))
    }
}

// MARK: - 2. Contact Details Sheet (showContact)
struct GavinContactSheetView: View {
    @ObservedObject var store: LociStoaStore
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        guard let cur = store.currentContact else { return AnyView(EmptyView()) }
        let isFav = store.favs[cur.email] ?? false
        let contactRows: [(label: String, value: String)] = [
            ("Department", cur.dept),
            ("Office", cur.office),
            ("Phone", cur.phone),
            ("Email", cur.email)
        ]
        
        return AnyView(
            VStack(alignment: .leading, spacing: 14) {
                // Drag Handle
                Capsule()
                    .fill(theme.strong)
                    .frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity)
                
                // Top Avatar + Name + Role + Close Button
                HStack(alignment: .top, spacing: 14) {
                    Text(cur.initials)
                        .font(LociFont.display(22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(theme.ink)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cur.name)
                            .font(LociFont.display(22, weight: .heavy))
                            .foregroundColor(theme.ink)
                        Text(cur.role)
                            .font(LociFont.sans(14))
                            .foregroundColor(theme.sub)
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) {
                            store.sheet = nil
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(theme.tint)
                                .frame(width: 44, height: 44)
                            LociIcon(kind: .close, size: 18, lineWidth: 2.4, color: theme.ink)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                
                // 4 Action Tiles: Email, Call, Map, Save/Saved
                HStack(spacing: 8) {
                    // Email Tile
                    Button(action: {
                        if let mailURL = URL(string: "mailto:\(cur.email)") {
                            #if os(iOS)
                            UIApplication.shared.open(mailURL)
                            #elseif os(macOS)
                            NSWorkspace.shared.open(mailURL)
                            #endif
                        }
                    }) {
                        VStack(spacing: 5) {
                            LociIcon(kind: .mail, size: 20, lineWidth: 2, color: .white)
                            Text("Email")
                                .font(LociFont.sans(12.5, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    // Call Tile
                    Button(action: {
                        if let telURL = URL(string: "tel://\(cur.phone)") {
                            #if os(iOS)
                            UIApplication.shared.open(telURL)
                            #elseif os(macOS)
                            NSWorkspace.shared.open(telURL)
                            #endif
                        }
                    }) {
                        VStack(spacing: 5) {
                            LociIcon(kind: .phone, size: 20, lineWidth: 2, color: theme.ink)
                            Text("Call")
                                .font(LociFont.sans(12.5, weight: .bold))
                                .foregroundColor(theme.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    // Map Tile
                    Button(action: {
                        store.contactToMap()
                    }) {
                        VStack(spacing: 5) {
                            LociIcon(kind: .mapPin, size: 20, lineWidth: 2, color: theme.ink)
                            Text("Map")
                                .font(LociFont.sans(12.5, weight: .bold))
                                .foregroundColor(theme.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    // Save / Saved Tile
                    Button(action: {
                        store.toggleFavForCurrentContact()
                    }) {
                        VStack(spacing: 5) {
                            LociIcon(kind: .star, size: 20, lineWidth: 2, color: theme.ink, filled: isFav)
                            Text(isFav ? "Saved" : "Save")
                                .font(LociFont.sans(12.5, weight: .bold))
                                .foregroundColor(theme.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                
                // Info Rows Card
                VStack(spacing: 0) {
                    ForEach(Array(contactRows.enumerated()), id: \.offset) { idx, r in
                        VStack(spacing: 0) {
                            if idx > 0 {
                                Rectangle().fill(theme.rule).frame(height: 1)
                            }
                            HStack(spacing: 16) {
                                Text(r.label)
                                    .font(LociFont.sans(13.5))
                                    .foregroundColor(theme.sub)
                                Spacer()
                                Text(r.value)
                                    .font(LociFont.sans(14.5, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.vertical, 8)
                            .frame(minHeight: 50)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
                
                // Locate Office on Interactive Indoor Map (Original LociStoa deep-link feature)
                if cur.office != "Not listed" {
                    Button(action: {
                        store.locatePersonOnInteractiveMap(cur)
                    }) {
                        HStack(spacing: 8) {
                            LociIcon(kind: .mapPin, size: 18, lineWidth: 2.2, color: .white)
                            Text("\(cur.office) · Locate on Indoor Map")
                                .font(LociFont.sans(14.5, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                            LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: .white)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 50)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                
                // See the whole department button
                Button(action: {
                    store.contactToDept()
                }) {
                    HStack {
                        Text("See the whole department")
                            .font(LociFont.sans(15, weight: .bold))
                            .foregroundColor(theme.ink)
                        Spacer()
                        LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(theme.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(LociPressButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .background(Color.white)
            .clipShape(GavinTopRoundedCorners(radius: 28))
        )
    }
}

// MARK: - 3. Add Task Sheet (showAdd — combines Gavin chips + original ToDoItem description & DatePicker)
struct GavinAddTaskSheetView: View {
    @ObservedObject var store: LociStoaStore
    private var theme: LociTheme { store.theme }
    
    private let taskTypes = ["Assignment", "Exam", "Project", "Reading", "Other"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // Drag Handle
                Capsule()
                    .fill(theme.strong)
                    .frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity)
                
                // Header
                HStack {
                    Text("Add task")
                        .font(LociFont.display(24, weight: .heavy))
                        .foregroundColor(theme.ink)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) {
                            store.sheet = nil
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(theme.tint)
                                .frame(width: 44, height: 44)
                            LociIcon(kind: .close, size: 18, lineWidth: 2.4, color: theme.ink)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Type Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("TYPE")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    LociFlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(taskTypes, id: \.self) { t in
                            GavinChipButton(
                                label: t,
                                isSelected: store.addType == t,
                                theme: theme
                            ) {
                                store.addType = t
                            }
                        }
                    }
                }
                
                // Course Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("COURSE")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    let activeCourse = store.selectedAddCourse
                    LociFlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(store.courseOptionsForTask, id: \.self) { c in
                            GavinChipButton(
                                label: c,
                                isSelected: activeCourse == c,
                                theme: theme
                            ) {
                                store.addCourse = c
                            }
                        }
                    }
                }
                
                // Description (Optional — Original AddItemView feature)
                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIPTION (OPTIONAL)")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    TextField("Description (Optional)", text: $store.addDescription)
                        .font(LociFont.sans(15.5))
                        .foregroundColor(theme.ink)
                        .padding(.horizontal, 14)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(theme.strong, lineWidth: 1.5)
                        )
                }
                
                // Due Date Picker (Original AddItemView feature)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("DUE DATE")
                            .font(LociFont.sans(12, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.sub)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                store.addHasDueDate.toggle()
                            }
                        }) {
                            Text(store.addHasDueDate ? "Clear date" : "Set due date")
                                .font(LociFont.sans(12.5, weight: .bold))
                                .foregroundColor(theme.accent)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if store.addHasDueDate {
                        DatePicker("Due Date", selection: $store.addDueDate, displayedComponents: .date)
                            .font(LociFont.sans(15, weight: .semibold))
                            .foregroundColor(theme.ink)
                            .tint(theme.accent)
                            .padding(.horizontal, 14)
                            .frame(height: 50)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(theme.strong, lineWidth: 1.5)
                            )
                    } else {
                        HStack {
                            Text("No due date")
                                .font(LociFont.sans(15))
                                .foregroundColor(theme.sub)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 50)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                
                // Save Task Button
                Button(action: {
                    store.saveTask()
                }) {
                    Text("Save task")
                        .font(LociFont.sans(16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(LociPressButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(maxHeight: 650)
        .background(Color.white)
        .clipShape(GavinTopRoundedCorners(radius: 28))
    }
}

// MARK: - 4. Add Class Sheet (showClass)
struct GavinAddClassSheetView: View {
    @ObservedObject var store: LociStoaStore
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // Drag Handle
                Capsule()
                    .fill(theme.strong)
                    .frame(width: 40, height: 5)
                    .frame(maxWidth: .infinity)
                
                // Header
                HStack {
                    Text("Add class")
                        .font(LociFont.display(24, weight: .heavy))
                        .foregroundColor(theme.ink)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.22)) {
                            store.sheet = nil
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(theme.tint)
                                .frame(width: 44, height: 44)
                            LociIcon(kind: .close, size: 18, lineWidth: 2.4, color: theme.ink)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Subject Input + Autocomplete Chips
                VStack(alignment: .leading, spacing: 8) {
                    Text("SUBJECT")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    TextField("Type a code or name, like MIS", text: Binding(
                        get: { store.cSubjQuery },
                        set: { newVal in
                            store.cSubjQuery = newVal
                            store.cSubj = nil
                        }
                    ))
                    .font(LociFont.sans(16))
                    .foregroundColor(theme.ink)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(theme.strong, lineWidth: 1.5)
                    )
                    
                    let matches = store.subjectAutocompleteMatches
                    if !matches.isEmpty {
                        LociFlowLayout(spacing: 8, lineSpacing: 8) {
                            ForEach(matches) { m in
                                Button(action: {
                                    store.cSubj = m.code
                                    store.cSubjQuery = "\(m.code) · \(m.name)"
                                    store.cErr = ""
                                }) {
                                    Text("\(m.code) · \(m.name)")
                                        .font(LociFont.sans(14, weight: .semibold))
                                        .foregroundColor(theme.ink)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .frame(minHeight: 44)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(theme.strong, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // Course Number Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("COURSE NUMBER")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    TextField("4000", text: $store.cNum)
                        .font(LociFont.sans(16))
                        .foregroundColor(theme.ink)
                        #if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
                        #endif
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(theme.strong, lineWidth: 1.5)
                        )
                }
                
                // Days 5-Column Grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("DAYS")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    HStack(spacing: 8) {
                        ForEach(LociStoaStore.daysInfo, id: \.code) { d in
                            let isOn = (store.cDays[d.code] == true)
                            Button(action: {
                                store.cDays[d.code] = !isOn
                                store.cErr = ""
                            }) {
                                Text(d.label)
                                    .font(LociFont.sans(14, weight: .bold))
                                    .foregroundColor(isOn ? .white : theme.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(isOn ? theme.ink : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(isOn ? theme.ink : theme.strong, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Starts & Ends Time Pickers / Inputs
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STARTS")
                            .font(LociFont.sans(12, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.sub)
                        
                        GavinTimeFieldBox(timeString: $store.cStart, theme: theme)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ENDS")
                            .font(LociFont.sans(12, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.sub)
                        
                        GavinTimeFieldBox(timeString: $store.cEnd, theme: theme)
                    }
                }
                
                // Building and Room (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("BUILDING AND ROOM (OPTIONAL)")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    TextField("Fisher 135", text: $store.cLoc)
                        .font(LociFont.sans(16))
                        .foregroundColor(theme.ink)
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(theme.strong, lineWidth: 1.5)
                        )
                }
                
                // Validation Error Alert
                if !store.cErr.isEmpty {
                    Text(store.cErr)
                        .font(LociFont.sans(14, weight: .semibold))
                        .foregroundColor(Color(hex: 0x8C1D18))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: 0xFDECEA))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                // Save Class Button
                Button(action: {
                    store.saveClass()
                }) {
                    Text("Save class")
                        .font(LociFont.sans(16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(LociPressButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .frame(maxHeight: 680)
        .background(Color.white)
        .clipShape(GavinTopRoundedCorners(radius: 28))
    }
}

private struct GavinTimeFieldBox: View {
    @Binding var timeString: String
    let theme: LociTheme
    
    private var dateBinding: Binding<Date> {
        Binding<Date>(
            get: {
                let parts = timeString.split(separator: ":")
                let h = Int(parts.first ?? "10") ?? 10
                let m = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
                return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
            },
            set: { newDate in
                let cal = Calendar.current
                let h = cal.component(.hour, from: newDate)
                let m = cal.component(.minute, from: newDate)
                let hStr = h < 10 ? "0\(h)" : "\(h)"
                let mStr = m < 10 ? "0\(m)" : "\(m)"
                timeString = "\(hStr):\(mStr)"
            }
        )
    }
    
    var body: some View {
        HStack {
            DatePicker("", selection: dateBinding, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(theme.accent)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.strong, lineWidth: 1.5)
        )
    }
}

// MARK: - 5. Global Search Sheet (showSearch)
struct GavinSearchSheetView: View {
    @ObservedObject var store: LociStoaStore
    private var theme: LociTheme { store.theme }
    private let suggestions = ["Transcript", "Parking", "Tutoring", "MUB"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Drag Handle
            Capsule()
                .fill(theme.strong)
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
            
            // Search Input + Cancel Button
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    LociIcon(kind: .search, size: 20, lineWidth: 2.2, color: theme.ink)
                    TextField("Search people, places, and tools", text: $store.query)
                        .font(LociFont.sans(16))
                        .foregroundColor(theme.ink)
                }
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.ink, lineWidth: 2)
                )
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.22)) {
                        store.sheet = nil
                    }
                }) {
                    Text("Cancel")
                        .font(LociFont.sans(15, weight: .bold))
                        .foregroundColor(theme.ink)
                        .padding(.horizontal, 4)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
            
            let qTrimmed = store.query.trimmingCharacters(in: .whitespacesAndNewlines)
            if qTrimmed.isEmpty {
                // Idle Suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("TRY")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(0.96)
                        .foregroundColor(theme.sub)
                    
                    LociFlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button(action: {
                                store.query = s
                            }) {
                                Text(s)
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
                }
            }
            
            // Search Results ScrollView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    // 1. Campus Lingo Hits
                    let lingoHits = store.searchLingoHits
                    if !lingoHits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CAMPUS LINGO")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(lingoHits.enumerated()), id: \.element.id) { idx, l in
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: {
                                            store.go(.map, building: l.buildingId, floor: "1F", layer: "All")
                                        }) {
                                            HStack(spacing: 12) {
                                                Text(l.term)
                                                    .font(LociFont.sans(13, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 10)
                                                    .frame(minWidth: 40, minHeight: 40)
                                                    .background(theme.ink)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(l.meaning)
                                                        .font(LociFont.sans(15, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text("\"\(l.term)\" is campus lingo for this · Show on map")
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                }
                                                Spacer()
                                            }
                                            .frame(minHeight: 62)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    
                    // 2. Offices That Can Help Hits
                    let officeHits = store.searchOfficeHits
                    if !officeHits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OFFICES THAT CAN HELP")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(officeHits.enumerated()), id: \.element.id) { idx, d in
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: {
                                            store.go(.people, pv: .help, resetPeopleSelection: true, office: d.id)
                                        }) {
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(d.name)
                                                        .font(LociFont.sans(15, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text(d.goHereFor)
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                }
                                                Spacer()
                                                LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                            }
                                            .padding(.vertical, 6)
                                            .frame(minHeight: 60)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    
                    // 3. People Hits
                    let peopleHits = store.searchPeopleHits
                    if !peopleHits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PEOPLE")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(peopleHits.enumerated()), id: \.element.id) { idx, c in
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: {
                                            store.openPersonSheet(c)
                                        }) {
                                            HStack(spacing: 12) {
                                                Text(c.initials)
                                                    .font(LociFont.sans(13, weight: .bold))
                                                    .foregroundColor(theme.ink)
                                                    .frame(width: 40, height: 40)
                                                    .background(theme.tint)
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(c.name)
                                                        .font(LociFont.sans(15, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text("\(c.role) · \(c.dept)")
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                        .lineLimit(1)
                                                }
                                                Spacer()
                                            }
                                            .frame(minHeight: 62)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    
                    // 4. Student Organizations Hits
                    let orgHits = store.searchOrgHits
                    if !orgHits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STUDENT ORGANIZATIONS")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(orgHits.enumerated()), id: \.element.id) { idx, o in
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: {
                                            store.go(.people, pv: .orgs, resetPeopleSelection: true, org: o.i)
                                        }) {
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(o.name)
                                                        .font(LociFont.sans(15, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text(o.cat)
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                }
                                                Spacer()
                                                LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                            }
                                            .padding(.vertical, 6)
                                            .frame(minHeight: 60)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    
                    // 5. Places & Tools Hits
                    let toolHits = store.searchToolHits
                    if !toolHits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PLACES & TOOLS")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(toolHits.enumerated()), id: \.element.id) { idx, s in
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: s.action) {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .fill(theme.tint)
                                                        .frame(width: 40, height: 40)
                                                    LociIcon(kind: s.icon, size: 20, lineWidth: 2, color: theme.ink)
                                                }
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(s.label)
                                                        .font(LociFont.sans(15, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text(s.sub)
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                }
                                                Spacer()
                                            }
                                            .frame(minHeight: 60)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Empty Search Hits
                    if store.searchNoHits {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nothing found")
                                .font(LociFont.display(19, weight: .bold))
                                .foregroundColor(theme.ink)
                            Text("Try a name, a department, something you need help with, or a building nickname.")
                                .font(LociFont.sans(14))
                                .foregroundColor(theme.sub)
                        }
                        .padding(.vertical, 22)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(height: 680)
        .background(theme.bg)
        .clipShape(GavinTopRoundedCorners(radius: 28))
    }
}

// MARK: - 6. Toast Banner (showToast)
struct GavinToastBanner: View {
    @ObservedObject var store: LociStoaStore
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(LociFont.sans(14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                store.undoToast()
            }) {
                Text("Undo")
                    .font(LociFont.sans(14, weight: .bold))
                    .underline()
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .frame(height: 52)
        .background(store.theme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(hex: 0x2B1F52, opacity: 0.3), radius: 12, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - 7. Call Confirmation Modal (showConfirm)
struct GavinCallConfirmDialog: View {
    @ObservedObject var store: LociStoaStore
    let confirmIndex: Int
    
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        let num = LociStoaStore.emergencyNumbers[confirmIndex]
        ZStack {
            Color(hex: 0x2B1F52, opacity: 0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        store.confirm = nil
                    }
                }
            
            VStack(spacing: 6) {
                Text("Call \(num.number)?")
                    .font(LociFont.display(23, weight: .heavy))
                    .foregroundColor(theme.ink)
                
                Text(num.label)
                    .font(LociFont.sans(14.5))
                    .foregroundColor(theme.sub)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            store.confirm = nil
                        }
                    }) {
                        Text("Cancel")
                            .font(LociFont.sans(16, weight: .bold))
                            .foregroundColor(theme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(theme.tint)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            store.confirm = nil
                        }
                    }) {
                        Text("Call")
                            .font(LociFont.sans(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(hex: 0xB3261E))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                .padding(.top, 14)
                
                Text("Calls are turned off in this prototype.")
                    .font(LociFont.sans(12.5))
                    .foregroundColor(theme.sub)
                    .padding(.top, 8)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(32)
        }
        .zIndex(40)
    }
}

// MARK: - 8. Ask LociStoa Chatbot View (Original DashboardSheet.chatbot styled in Gavin UI)
struct LociChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil
}

struct AskLociStoaChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: LociStoaStore
    @State private var inputText: String = ""
    @State private var messages: [LociChatMessage] = [
        LociChatMessage(
            isUser: false,
            text: "Hi! I'm Ask LociStoa, your Michigan Tech campus assistant. Ask me about any building, heated skywalk route, professor's office, campus lingo, or student resource!"
        )
    ]
    
    private var theme: LociTheme { store.theme }
    private let promptChips = [
        "How do I get to Rekhi 214 indoors?",
        "Where is the Registrar's Office?",
        "What does MEEM mean?",
        "Who is the CS Department Chair?",
        "Show Friday Period Schedule"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                store.effectiveBgColor.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Quick Prompt Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(promptChips, id: \.self) { prompt in
                                Button(action: {
                                    sendPrompt(prompt)
                                }) {
                                    Text(prompt)
                                        .font(LociFont.sans(13, weight: .semibold))
                                        .foregroundColor(theme.ink)
                                        .padding(.horizontal, 14)
                                        .frame(height: 38)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(theme.strong, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(LociPressButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
                    // Chat Messages
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(messages) { msg in
                                    HStack {
                                        if msg.isUser { Spacer(minLength: 40) }
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(msg.text)
                                                .font(LociFont.sans(15))
                                                .foregroundColor(msg.isUser ? .white : theme.ink)
                                                .lineSpacing(2)
                                            
                                            if let label = msg.actionLabel, let act = msg.action {
                                                Button(action: {
                                                    dismiss()
                                                    act()
                                                }) {
                                                    HStack(spacing: 6) {
                                                        Text(label)
                                                            .font(LociFont.sans(13, weight: .bold))
                                                        LociIcon(kind: .chevronRight, size: 14, lineWidth: 2.2, color: theme.ink)
                                                    }
                                                    .foregroundColor(theme.ink)
                                                    .padding(.horizontal, 14)
                                                    .frame(height: 36)
                                                    .background(theme.tint)
                                                    .clipShape(Capsule())
                                                }
                                                .buttonStyle(LociPressButtonStyle())
                                            }
                                        }
                                        .padding(14)
                                        .background(msg.isUser ? theme.accent : Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(msg.isUser ? theme.accent : theme.line, lineWidth: 1)
                                        )
                                        if !msg.isUser { Spacer(minLength: 40) }
                                    }
                                    .id(msg.id)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let lastId = messages.last?.id {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input Bar
                    HStack(spacing: 10) {
                        TextField("Ask about a room, person, office, or lingo...", text: $inputText)
                            .font(LociFont.sans(15.5))
                            .foregroundColor(theme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 50)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(theme.strong, lineWidth: 1.5)
                            )
                            .onSubmit {
                                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                inputText = ""
                                sendPrompt(trimmed)
                            }
                        
                        Button(action: {
                            let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            inputText = ""
                            sendPrompt(trimmed)
                        }) {
                            Text("Send")
                                .font(LociFont.sans(15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .frame(height: 50)
                                .background(theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }
            }
            .navigationTitle("Ask LociStoa")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(LociFont.sans(15, weight: .bold))
                        .foregroundColor(theme.ink)
                }
            }
        }
    }
    
    private func sendPrompt(_ prompt: String) {
        messages.append(LociChatMessage(isUser: true, text: prompt))
        let lower = prompt.lowercased()
        
        if lower.contains("214") || lower.contains("rekhi") || lower.contains("skywalk") || lower.contains("indoor") {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "Rekhi Hall connects directly to the Van Pelt & Opie Library and Fisher Hall via heated indoor skywalk bridges on 2F. You can view the turn-by-turn indoor blueprint route in the Live Interactive Map!",
                    actionLabel: "Open Live Interactive Map",
                    action: {
                        store.mapMode = .interactive
                        store.go(.map, building: "rekhi", floor: "2F")
                    }
                )
            )
        } else if lower.contains("registrar") || lower.contains("transcript") || lower.contains("financial") {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "The Registrar's Office and Student Financial Services are located on the 1st floor of the Administration Building (Admin 130 & Admin 103), open Mon–Fri 8 AM to 5 PM.",
                    actionLabel: "Open Registrar Details",
                    action: {
                        store.go(.people, pv: .help, resetPeopleSelection: true, office: "registrar")
                    }
                )
            )
        } else if lower.contains("meem") || lower.contains("mub") || lower.contains("wads") || lower.contains("sdc") || lower.contains("lingo") {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "Campus lingo decode:\n• MEEM: R. L. Smith Mechanical Engineering Building\n• MUB: Memorial Union Building\n• Wads: Wadsworth Hall\n• SDC: Student Development Complex",
                    actionLabel: "Open Campus Map",
                    action: {
                        store.go(.map, building: "meem")
                    }
                )
            )
        } else if lower.contains("friday") || lower.contains("period") || lower.contains("schedule") {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "Michigan Tech runs 8 standard class periods from 08:30 to 03:22, with an adjusted Period 1 bell on Fridays (08:30 - 09:17).",
                    actionLabel: "View Period Schedule",
                    action: {
                        store.go(.planner, planMode: .periods)
                    }
                )
            )
        } else if let matchedPerson = store.people.first(where: { $0.hay.contains(lower) || lower.contains($0.name.lowercased()) }) {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "\(matchedPerson.name) is \(matchedPerson.role) in \(matchedPerson.dept). Office: \(matchedPerson.office) · Email: \(matchedPerson.email).",
                    actionLabel: "Locate Office on Map",
                    action: {
                        store.locatePersonOnInteractiveMap(matchedPerson)
                    }
                )
            )
        } else if lower.contains("chair") || lower.contains("cs") || lower.contains("computer science") {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "Dr. Zhenlin Wang is Professor and Department Chair of Computer Science, located in Rekhi Hall 322 (906-487-2187, zlwang@mtu.edu).",
                    actionLabel: "See CS Department",
                    action: {
                        store.go(.people, pv: .depts, resetPeopleSelection: true, dept: "Computer Science")
                    }
                )
            )
        } else {
            messages.append(
                LociChatMessage(
                    isUser: false,
                    text: "You can search all \(store.people.count) faculty & staff, \(store.offices.count) campus support offices, \(store.orgs.count) student organizations, and 23 campus buildings right from LociStoa.",
                    actionLabel: "Open Global Search",
                    action: {
                        store.query = prompt
                        store.sheet = .search
                    }
                )
            )
        }
    }
}

// MARK: - 9. Campus Nomenclature & Lingo View (Original DashboardSheet.nomenclature styled in Gavin UI)
struct CampusNomenclatureView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: LociStoaStore
    @State private var searchText: String = ""
    
    private var theme: LociTheme { store.theme }
    
    private var filteredLingo: [GavinLingoItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return LociStoaStore.campusLingo }
        return LociStoaStore.campusLingo.filter {
            "\($0.term) \($0.meaning) \($0.details)".lowercased().contains(q)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                store.effectiveBgColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CAMPUS LINGO & ACRONYMS")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            Text("Nomenclature Guide")
                                .font(LociFont.display(32, weight: .heavy))
                                .foregroundColor(theme.ink)
                            Text("Decode Michigan Tech building nicknames, acronyms, and campus shorthand.")
                                .font(LociFont.sans(14.5))
                                .foregroundColor(theme.sub)
                        }
                        
                        // Search Input
                        HStack(spacing: 10) {
                            LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                            TextField("Search acronym or building name (e.g. MUB, MEEM, Wads)...", text: $searchText)
                                .font(LociFont.sans(15.5))
                                .foregroundColor(theme.ink)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    LociIcon(kind: .close, size: 16, lineWidth: 2.2, color: theme.sub)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(theme.strong, lineWidth: 1.5)
                        )
                        
                        // Lingo Cards
                        VStack(spacing: 12) {
                            ForEach(filteredLingo) { item in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 12) {
                                        Text(item.term)
                                            .font(LociFont.display(16, weight: .heavy))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .frame(minWidth: 58, minHeight: 40)
                                            .background(theme.ink)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.meaning)
                                                .font(LociFont.sans(16, weight: .bold))
                                                .foregroundColor(theme.ink)
                                            Text("Official Building Name")
                                                .font(LociFont.sans(12, weight: .semibold))
                                                .foregroundColor(theme.sub)
                                        }
                                        Spacer()
                                    }
                                    
                                    if !item.details.isEmpty {
                                        Text(item.details)
                                            .font(LociFont.sans(13.5))
                                            .foregroundColor(theme.sub)
                                            .lineSpacing(2)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            dismiss()
                                            store.mapMode = .diagram
                                            store.go(.map, building: item.buildingId, floor: "1F", layer: "All")
                                        }) {
                                            HStack(spacing: 6) {
                                                LociIcon(kind: .mapPin, size: 15, lineWidth: 2, color: theme.ink)
                                                Text("Show on Campus Diagram")
                                                    .font(LociFont.sans(13, weight: .bold))
                                                    .foregroundColor(theme.ink)
                                            }
                                            .padding(.horizontal, 14)
                                            .frame(height: 40)
                                            .background(theme.tint)
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(LociPressButtonStyle())
                                        
                                        Button(action: {
                                            dismiss()
                                            store.mapMode = .interactive
                                            store.go(.map, building: item.buildingId, floor: "1F", layer: "All")
                                        }) {
                                            HStack(spacing: 6) {
                                                LociIcon(kind: .map, size: 15, lineWidth: 2, color: .white)
                                                Text("Live Map")
                                                    .font(LociFont.sans(13, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, 14)
                                            .frame(height: 40)
                                            .background(theme.accent)
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(LociPressButtonStyle())
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(theme.line, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Campus Nomenclature")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(LociFont.sans(15, weight: .bold))
                        .foregroundColor(theme.ink)
                }
            }
        }
    }
}
