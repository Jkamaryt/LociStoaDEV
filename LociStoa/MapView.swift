import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var directoryVM = DirectoryViewModel()
    
    // Optional deep-link contact from DirectoryContactsView
    var focusedContact: Contact? = nil
    var isEmbeddedInTab: Bool = false
    var theme: LociTheme = .purple
    var onClose: (() -> Void)? = nil
    
    @State private var searchText: String = ""
    @State private var selectedCategory: MTULocationCategory = .all
    @State private var selectedBuilding: MTUBuilding
    @State private var winterSkywalkMode: Bool = false
    @State private var showActiveWalkingRoute: Bool = true
    @State private var showReferenceLandmarks: Bool = true
    
    // Indoor Floor Plan View State (rendered in-place to avoid nested sheet lockups)
    @State private var showingIndoorMap: Bool
    @State private var openedDirectlyToIndoor: Bool
    @State private var indoorTargetFloor: String?
    @State private var indoorTargetRoom: MTUFloorRoom?
    
    @State private var region: MKCoordinateRegion
    @State private var cameraPosition: MapCameraPosition
    
    init(
        focusedContact: Contact? = nil,
        isEmbeddedInTab: Bool = false,
        theme: LociTheme = .purple,
        onClose: (() -> Void)? = nil
    ) {
        self.focusedContact = focusedContact
        self.isEmbeddedInTab = isEmbeddedInTab
        self.theme = theme
        self.onClose = onClose
        
        if let contact = focusedContact,
           let match = MTUCampusData.matchBuilding(for: contact) {
            let startRegion = MKCoordinateRegion(
                center: match.building.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0028, longitudeDelta: 0.0038)
            )
            _selectedBuilding = State(initialValue: match.building)
            _region = State(initialValue: startRegion)
            _cameraPosition = State(initialValue: .region(startRegion))
            _indoorTargetFloor = State(initialValue: match.floorCode)
            _indoorTargetRoom = State(initialValue: match.room)
            _showingIndoorMap = State(initialValue: true)
            _openedDirectlyToIndoor = State(initialValue: true)
        } else {
            let defaultBuilding = MTUCampusData.buildings[0]
            let startRegion = MKCoordinateRegion(
                center: MTUCampusData.campusCenter,
                span: MKCoordinateSpan(latitudeDelta: 0.0046, longitudeDelta: 0.0064)
            )
            _selectedBuilding = State(initialValue: defaultBuilding)
            _region = State(initialValue: startRegion)
            _cameraPosition = State(initialValue: .region(startRegion))
            _indoorTargetFloor = State(initialValue: "3F")
            _indoorTargetRoom = State(initialValue: nil)
            _showingIndoorMap = State(initialValue: false)
            _openedDirectlyToIndoor = State(initialValue: false)
        }
    }
    
    private var filteredBuildings: [MTUBuilding] {
        MTUCampusData.buildings.filter { building in
            let matchesCategory = (selectedCategory == .all) || (building.category == selectedCategory)
            guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
                return matchesCategory
            }
            let query = searchText.trimmingCharacters(in: .whitespaces)
            let matchesBuildingText =
                building.name.localizedCaseInsensitiveContains(query) ||
                building.shortName.localizedCaseInsensitiveContains(query) ||
                building.primaryHighlight.localizedCaseInsensitiveContains(query) ||
                building.secondaryHighlight.localizedCaseInsensitiveContains(query) ||
                building.floors.flatMap(\.rooms).contains {
                    $0.title.localizedCaseInsensitiveContains(query) ||
                    $0.roomNumber.localizedCaseInsensitiveContains(query) ||
                    $0.subtitle.localizedCaseInsensitiveContains(query)
                }
            let matchesServerContact = directoryVM.contacts.contains { contact in
                (contact.name.localizedCaseInsensitiveContains(query) ||
                 contact.department.localizedCaseInsensitiveContains(query) ||
                 (contact.office ?? "").localizedCaseInsensitiveContains(query)) &&
                building.matchingOfficePrefixes.contains { (contact.office ?? "").localizedCaseInsensitiveContains($0) }
            }
            return matchesCategory && (matchesBuildingText || matchesServerContact)
        }
    }
    
    /// Direct office/room search matches across all 12 buildings when the user types in the search bar
    private var matchingOfficeResults: [(building: MTUBuilding, floorCode: String, room: MTUFloorRoom)] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        var results: [(MTUBuilding, String, MTUFloorRoom)] = []
        for building in MTUCampusData.buildings {
            for floor in building.floors {
                for room in floor.rooms {
                    if room.title.localizedCaseInsensitiveContains(query) ||
                       room.roomNumber.localizedCaseInsensitiveContains(query) ||
                       room.subtitle.localizedCaseInsensitiveContains(query) ||
                       room.roleBadge.localizedCaseInsensitiveContains(query) {
                        results.append((building, floor.levelCode, room))
                    }
                }
            }
        }
        return Array(results.prefix(8))
    }
    
    /// Contacts whose office is inside the selected building
    private var contactsInSelectedBuilding: [Contact] {
        directoryVM.contacts.filter { contact in
            guard let office = contact.office else { return false }
            return selectedBuilding.matchingOfficePrefixes.contains {
                office.localizedCaseInsensitiveContains($0)
            }
        }
    }
    
    private var horizontalPad: CGFloat {
        isEmbeddedInTab ? 0 : 18
    }
    
    var body: some View {
        Group {
            if isEmbeddedInTab {
                campusMapStackContent
                    .sheet(isPresented: $showingIndoorMap) {
                        MTUIndoorMapView(
                            building: selectedBuilding,
                            initialFloorCode: indoorTargetFloor,
                            initialRoom: indoorTargetRoom,
                            directoryContacts: directoryVM.contacts,
                            onBackToCampusMap: {
                                showingIndoorMap = false
                            },
                            onClose: {
                                showingIndoorMap = false
                            }
                        )
                    }
            } else if showingIndoorMap {
                MTUIndoorMapView(
                    building: selectedBuilding,
                    initialFloorCode: indoorTargetFloor,
                    initialRoom: indoorTargetRoom,
                    directoryContacts: directoryVM.contacts,
                    onBackToCampusMap: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            openedDirectlyToIndoor = false
                            showingIndoorMap = false
                        }
                    },
                    onClose: {
                        if openedDirectlyToIndoor {
                            closeSheet()
                        } else {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showingIndoorMap = false
                            }
                        }
                    }
                )
                .transition(.opacity)
            } else {
                campusMapBody
                    .transition(.opacity)
            }
        }
        .task {
            if directoryVM.contacts.isEmpty {
                await directoryVM.fetchContacts()
            }
        }
    }
    
    private var campusMapBody: some View {
        NavigationStack {
            ZStack {
                theme.bg.ignoresSafeArea()
                campusMapStackContent
            }
            .navigationTitle("Live Interactive Map")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        closeSheet()
                    }
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.ink)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        indoorTargetFloor = selectedBuilding.floors.first?.levelCode ?? "1F"
                        indoorTargetRoom = selectedBuilding.floors.first?.rooms.first
                        openedDirectlyToIndoor = false
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingIndoorMap = true
                        }
                    }) {
                        Label("Indoor Map", systemImage: "building.2.fill")
                            .foregroundColor(theme.accent)
                    }
                }
            }
        }
    }
    
    private var campusMapStackContent: some View {
        VStack(spacing: 12) {
            // 1. Search Bar for MTU Buildings, Rooms, or Professors (Gavin UI Style)
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                    TextField("Search any office, room #, professor, or building...", text: $searchText)
                        .font(LociFont.sans(15))
                        .foregroundColor(theme.ink)
                        .onSubmit {
                            if let firstOffice = matchingOfficeResults.first {
                                openOfficeDirectly(firstOffice.building, floorCode: firstOffice.floorCode, room: firstOffice.room)
                            } else if let firstMatch = filteredBuildings.first {
                                focusOnBuilding(firstMatch)
                            }
                        }
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            LociIcon(kind: .close, size: 16, lineWidth: 2.2, color: theme.sub)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.strong, lineWidth: 1.5)
                )
                
                // Instant Direct-to-Office Search Results Strip
                if !matchingOfficeResults.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(matchingOfficeResults, id: \.room.id) { match in
                                Button(action: {
                                    openOfficeDirectly(match.building, floorCode: match.floorCode, room: match.room)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: match.room.kind.icon)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(match.room.kind.color)
                                            .clipShape(Circle())
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("\(match.room.title) • \(match.room.roomNumber)")
                                                .font(LociFont.sans(12, weight: .bold))
                                                .foregroundColor(theme.ink)
                                            Text("\(match.building.shortName) (\(match.floorCode)) • Tap to route inside")
                                                .font(LociFont.sans(10.5, weight: .semibold))
                                                .foregroundColor(theme.accent)
                                        }
                                        LociIcon(kind: .externalArrow, size: 13, lineWidth: 2.2, color: theme.accent)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
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
                    }
                }
            }
            .padding(.horizontal, horizontalPad)
            
            // 2. Horizontal Category Filter Pills (Gavin Chip Style)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MTULocationCategory.allCases) { category in
                        let isSelected = (selectedCategory == category)
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedCategory = category
                                if let first = filteredBuildings.first, !filteredBuildings.contains(selectedBuilding) {
                                    focusOnBuilding(first)
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(category.tintColor)
                                    .frame(width: 9, height: 9)
                                Text(category.rawValue)
                                    .font(LociFont.sans(13.5, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : theme.ink)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 40)
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
                .padding(.horizontal, horizontalPad)
            }
            
            // 3. Winter Skywalk & Course Schedule Sync Card (Gavin Card Style)
            VStack(spacing: 9) {
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(theme.tint)
                                .frame(width: 38, height: 38)
                            Image(systemName: winterSkywalkMode ? "snowflake.circle.fill" : "snowflake")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(theme.accent)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Winter Skywalk & Indoor Route")
                                .font(LociFont.sans(14, weight: .bold))
                                .foregroundColor(theme.ink)
                            Text(winterSkywalkMode ? "Heated skywalks & tunnels highlighted" : "Toggle for snow-free indoor building connectors")
                                .font(LociFont.sans(12))
                                .foregroundColor(theme.sub)
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            winterSkywalkMode.toggle()
                        }
                    }) {
                        ZStack(alignment: winterSkywalkMode ? .trailing : .leading) {
                            Capsule()
                                .fill(winterSkywalkMode ? theme.accent : theme.check)
                                .frame(width: 50, height: 30)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .shadow(color: .black.opacity(0.25), radius: 1.5, x: 0, y: 1)
                                .padding(.horizontal, 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Rectangle().fill(theme.rule).frame(height: 1)
                
                HStack {
                    Label("Next Class: 10:13 - 11:07 • Rekhi Hall 214", systemImage: "calendar.badge.clock")
                        .font(LociFont.sans(12, weight: .bold))
                        .foregroundColor(theme.ink)
                    Spacer()
                    Button("Route to Rm 214") {
                        if let rekhi = MTUCampusData.buildings.first(where: { $0.id == "rekhi" }),
                           let floor2 = rekhi.floors.first(where: { $0.levelCode == "2F" }),
                           let room214 = floor2.rooms.first(where: { $0.roomNumber == "Rm 214" }) {
                            winterSkywalkMode = true
                            showActiveWalkingRoute = true
                            openOfficeDirectly(rekhi, floorCode: "2F", room: room214)
                        }
                    }
                    .font(LociFont.sans(12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.tint)
                    .foregroundColor(theme.ink)
                    .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
            .padding(.horizontal, horizontalPad)
            
            // 4. Interactive Campus Map with Differentiated Building Pins, Reference Landmarks & Routes
            ZStack {
                Map(position: $cameraPosition) {
                    // A. Heated Skywalk Network Polylines
                    if winterSkywalkMode {
                        ForEach(MTUCampusData.skywalkSegments) { segment in
                            MapPolyline(coordinates: [segment.fromCoord, segment.toCoord])
                                .stroke(
                                    Color.cyan,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [6, 5])
                                )
                        }
                    }
                    
                    // B. Active Campus Walking Route Polyline from Central Hub to Selected Building
                    if showActiveWalkingRoute {
                        let routeCoords = MTUCampusData.campusRouteCoordinates(to: selectedBuilding, winterMode: winterSkywalkMode)
                        MapPolyline(coordinates: routeCoords)
                            .stroke(
                                theme.accent,
                                style: StrokeStyle(lineWidth: 4.5, lineCap: .round, lineJoin: .round, dash: [8, 5])
                            )
                    }
                    
                    // C. Spatial Reference Landmarks & Shuttle Stops
                    if showReferenceLandmarks {
                        ForEach(MTUCampusData.campusLandmarks) { landmark in
                            Annotation(landmark.name, coordinate: landmark.coordinate) {
                                HStack(spacing: 4) {
                                    Image(systemName: landmark.icon)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text(landmark.name)
                                        .font(.system(size: 8.5, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary.opacity(0.85))
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.88))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.orange.opacity(0.45), lineWidth: 1))
                            }
                            .annotationTitles(.hidden)
                        }
                        
                        ForEach(MTUCampusData.shuttleStops) { stop in
                            Annotation(stop.name, coordinate: stop.coordinate) {
                                HStack(spacing: 3) {
                                    Image(systemName: "bus.fill")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text("\(stop.etaMinutes)m")
                                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .background(Color.white.opacity(0.92))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.blue.opacity(0.4), lineWidth: 1))
                            }
                            .annotationTitles(.hidden)
                        }
                    }
                    
                    // D. Differentiated Campus Building Pins with Building # and Category Color
                    ForEach(filteredBuildings) { building in
                        Annotation(building.shortName, coordinate: building.coordinate) {
                            let isSelected = (selectedBuilding.id == building.id)
                            let catColor = building.category.tintColor
                            Button(action: {
                                focusOnBuilding(building)
                            }) {
                                VStack(spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text("#\(building.buildingNumber)")
                                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(isSelected ? Color.white.opacity(0.25) : catColor.opacity(0.16))
                                            .foregroundColor(isSelected ? .white : catColor)
                                            .clipShape(Capsule())
                                        
                                        Text(building.shortName)
                                            .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                            .foregroundColor(isSelected ? .white : theme.ink)
                                        
                                        if building.hasSkywalkAccess && winterSkywalkMode {
                                            Image(systemName: "snowflake")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(isSelected ? .white : .cyan)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(isSelected ? theme.ink : Color.white)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.white : catColor.opacity(0.55), lineWidth: isSelected ? 1.5 : 1)
                                    )
                                    .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                                    
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(isSelected ? theme.ink : catColor)
                                        .offset(y: -2)
                                }
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                            }
                            .buttonStyle(.plain)
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .onMapCameraChange { context in
                    region = context.region
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(winterSkywalkMode ? theme.accent : theme.strong, lineWidth: winterSkywalkMode ? 2.5 : 1)
                )
                
                // Top Floating Map Controls (Reference Landmarks Toggle + Shuttle Pill)
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showReferenceLandmarks.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: showReferenceLandmarks ? "eye.fill" : "eye.slash")
                                    .font(.caption2)
                                Text(showReferenceLandmarks ? "Landmarks On" : "Landmarks Off")
                                    .font(LociFont.sans(11.5, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.95))
                            .foregroundColor(theme.ink)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            Text("Husky Shuttle • 2m")
                                .font(LociFont.sans(11.5, weight: .bold))
                                .foregroundColor(theme.ink)
                            Text("🚌")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.95))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(theme.line, lineWidth: 1))
                        .allowsHitTesting(false)
                    }
                    .padding(10)
                    
                    Spacer()
                    
                    // Bottom-Right Map Zoom & Route Toggle Controls
                    HStack(alignment: .bottom) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showActiveWalkingRoute.toggle()
                            }
                        }) {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(showActiveWalkingRoute ? theme.accent : Color.secondary)
                                    .frame(width: 8, height: 8)
                                Text(showActiveWalkingRoute ? "Route to #\(selectedBuilding.buildingNumber) Active" : "Show Campus Route")
                                    .font(LociFont.sans(11.5, weight: .bold))
                                    .foregroundColor(theme.ink)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        VStack(spacing: 0) {
                            Button(action: { zoomMap(factor: 0.65) }) {
                                Image(systemName: "plus")
                                    .font(.subheadline.bold())
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(theme.ink)
                            }
                            Divider()
                                .frame(width: 24)
                            Button(action: { zoomMap(factor: 1.45) }) {
                                Image(systemName: "minus")
                                    .font(.subheadline.bold())
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(theme.ink)
                            }
                        }
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                    }
                    .padding(10)
                }
            }
            .frame(minHeight: isEmbeddedInTab ? 330 : 280)
            .padding(.horizontal, horizontalPad)
            
            // 5. Bottom Building / Spatial Reference / Indoor Floor Plan Card (Gavin Card Style)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Bldg #\(selectedBuilding.buildingNumber)")
                                .font(LociFont.sans(11.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(theme.tint)
                                .foregroundColor(theme.ink)
                                .clipShape(Capsule())
                            Text(selectedBuilding.name)
                                .font(LociFont.display(18, weight: .bold))
                                .foregroundColor(theme.ink)
                                .lineLimit(1)
                        }
                        Text(selectedBuilding.relativeCampusDescription)
                            .font(LociFont.sans(12, weight: .semibold))
                            .foregroundColor(theme.sub)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(selectedBuilding.floors.count) Floors • \(selectedBuilding.floors.flatMap(\.rooms).count) Rooms")
                        .font(LociFont.sans(11.5, weight: .bold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(theme.tint)
                        .foregroundColor(theme.ink)
                        .clipShape(Capsule())
                }
                
                if winterSkywalkMode {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Winter Indoor/Connector Route", systemImage: "snowflake")
                                .font(LociFont.sans(12, weight: .bold))
                                .foregroundColor(theme.accent)
                            Spacer()
                            Text("\(selectedBuilding.walkMinutesIndoor) min walk • Avoids snow")
                                .font(LociFont.sans(12, weight: .bold))
                                .foregroundColor(theme.accent)
                        }
                        Text(selectedBuilding.skywalkRouteSummary)
                            .font(LociFont.sans(13, weight: .semibold))
                            .foregroundColor(theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .background(theme.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedBuilding.primaryHighlight)
                                .font(LociFont.sans(13, weight: .bold))
                                .foregroundColor(theme.ink)
                            Text(selectedBuilding.secondaryHighlight)
                                .font(LociFont.sans(12))
                                .foregroundColor(theme.sub)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(theme.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // Action Row: Open Indoor Floor Plan & Route + Apple Maps
                HStack(spacing: 8) {
                    Button(action: {
                        indoorTargetFloor = selectedBuilding.floors.first?.levelCode ?? "1F"
                        indoorTargetRoom = selectedBuilding.floors.first?.rooms.first
                        openedDirectlyToIndoor = false
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingIndoorMap = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "building.2.crop.circle.fill")
                            Text("Explore Indoor Floor Plan (\(selectedBuilding.floors.flatMap(\.rooms).count) Offices)")
                                .font(LociFont.sans(13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    Button(action: {
                        openWalkingDirections(to: selectedBuilding)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "paperplane.fill")
                            Text("\(winterSkywalkMode ? selectedBuilding.walkMinutesIndoor : selectedBuilding.walkMinutesOutdoor)m GPS")
                                .font(LociFont.sans(13, weight: .bold))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(theme.tint)
                        .foregroundColor(theme.ink)
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
            .padding(.horizontal, horizontalPad)
            .padding(.bottom, isEmbeddedInTab ? 0 : 8)
        }
    }
    
    // MARK: - Map Helpers
    private func closeSheet() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }
    
    private func openOfficeDirectly(_ building: MTUBuilding, floorCode: String, room: MTUFloorRoom) {
        selectedBuilding = building
        indoorTargetFloor = floorCode
        indoorTargetRoom = room
        openedDirectlyToIndoor = false
        withAnimation(.easeInOut(duration: 0.25)) {
            showingIndoorMap = true
        }
    }
    
    private func focusOnBuilding(_ building: MTUBuilding) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedBuilding = building
            showActiveWalkingRoute = true
            let newRegion = MKCoordinateRegion(
                center: building.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0028, longitudeDelta: 0.0038)
            )
            region = newRegion
            cameraPosition = .region(newRegion)
        }
    }
    
    private func zoomMap(factor: Double) {
        withAnimation(.easeInOut(duration: 0.25)) {
            let newLat = max(0.001, min(0.025, region.span.latitudeDelta * factor))
            let newLon = max(0.001, min(0.025, region.span.longitudeDelta * factor))
            let newRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLon)
            )
            region = newRegion
            cameraPosition = .region(newRegion)
        }
    }
    
    private func openWalkingDirections(to building: MTUBuilding) {
        let urlString = "http://maps.apple.com/?daddr=\(building.latitude),\(building.longitude)&dirflg=w"
        if let url = URL(string: urlString) {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
}

// MARK: - Xcode Previews
#Preview("1. MTU Campus Explorer") {
    MapView()
}

#Preview("2. Rekhi Hall Indoor Office Map") {
    MTUIndoorMapView(
        building: MTUCampusData.buildings[0],
        initialFloorCode: "3F"
    )
}
