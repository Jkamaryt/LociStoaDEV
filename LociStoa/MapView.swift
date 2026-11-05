import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var directoryVM = DirectoryViewModel()
    
    // Optional deep-link contact from DirectoryContactsView
    var focusedContact: Contact? = nil
    
    @State private var searchText: String = ""
    @State private var selectedCategory: MTULocationCategory = .all
    @State private var selectedBuilding: MTUBuilding = MTUCampusData.buildings[0]
    @State private var winterSkywalkMode: Bool = false
    @State private var showActiveWalkingRoute: Bool = false
    
    // Indoor Floor Plan Sheet State
    @State private var showingIndoorMap: Bool = false
    @State private var indoorTargetFloor: String? = "3F"
    @State private var indoorTargetRoom: MTUFloorRoom? = nil
    
    @State private var region = MKCoordinateRegion(
        center: MTUCampusData.campusCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.0042, longitudeDelta: 0.0058)
    )
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: MTUCampusData.campusCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.0042, longitudeDelta: 0.0058)
        )
    )
    
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
    
    /// Contacts from server.py / contacts.json whose office is inside the selected building
    private var contactsInSelectedBuilding: [Contact] {
        directoryVM.contacts.filter { contact in
            guard let office = contact.office else { return false }
            return selectedBuilding.matchingOfficePrefixes.contains {
                office.localizedCaseInsensitiveContains($0)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // 1. Search Bar for MTU Buildings, Centers, or Professors
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(lociAccent)
                        TextField("Search MTU buildings, centers, or professors...", text: $searchText)
                            .font(.subheadline)
                            .onSubmit {
                                if let firstMatch = filteredBuildings.first {
                                    focusOnBuilding(firstMatch)
                                }
                            }
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
                    .padding(.horizontal, 20)
                    
                    // 2. Horizontal Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
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
                                        Image(systemName: category.icon)
                                            .font(.caption)
                                        Text(category.rawValue)
                                            .font(.caption.bold())
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(isSelected ? lociAccent : Color.white.opacity(0.75))
                                    .foregroundColor(isSelected ? .white : lociAccent)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(lociAccent.opacity(isSelected ? 0 : 0.45), lineWidth: 1.2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 3. Winter Skywalk & Course Schedule Sync Card (Concept 3)
                    VStack(spacing: 8) {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: winterSkywalkMode ? "snowflake.circle.fill" : "snowflake")
                                    .font(.title3)
                                    .foregroundColor(lociAccent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Winter Skywalk & Indoor Route")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                    Text(winterSkywalkMode ? "Heated skywalks & tunnels active" : "Toggle for snow-free indoor connectors")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Toggle("", isOn: $winterSkywalkMode.animation(.spring()))
                                .labelsHidden()
                                .tint(lociAccent)
                        }
                        
                        Divider()
                        
                        HStack {
                            Label("Next Class: 10:13 - 11:07 • Rekhi Hall 214", systemImage: "calendar.badge.clock")
                                .font(.caption.bold())
                                .foregroundColor(lociAccent)
                            Spacer()
                            Button("Route Now") {
                                if let rekhi = MTUCampusData.buildings.first(where: { $0.id == "rekhi" }) {
                                    winterSkywalkMode = true
                                    showActiveWalkingRoute = true
                                    focusOnBuilding(rekhi)
                                }
                            }
                            .font(.caption2.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(lociAccent.opacity(0.15))
                            .foregroundColor(lociAccent)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                    .padding(.horizontal, 20)
                    
                    // 4. Interactive Campus Map with Custom Pins, Shuttle Badge & Zoom Controls
                    ZStack {
                        Map(position: $cameraPosition) {
                            if winterSkywalkMode {
                                ForEach(MTUCampusData.skywalkSegments) { segment in
                                    MapPolyline(coordinates: [segment.fromCoord, segment.toCoord])
                                        .stroke(
                                            lociAccent,
                                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [7, 5])
                                        )
                                }
                            }
                            
                            ForEach(filteredBuildings) { building in
                                Annotation(building.shortName, coordinate: building.coordinate) {
                                    let isSelected = (selectedBuilding.id == building.id)
                                    Button(action: {
                                        focusOnBuilding(building)
                                    }) {
                                        VStack(spacing: 3) {
                                            HStack(spacing: 4) {
                                                Image(systemName: building.hasSkywalkAccess && winterSkywalkMode ? "snowflake" : "mappin.circle.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(isSelected ? .white : lociAccent)
                                                Text(building.shortName)
                                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                                    .foregroundColor(isSelected ? .white : .primary)
                                            }
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(isSelected ? lociAccent : Color.white)
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                                            
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(isSelected ? lociAccent : .orange)
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
                                .stroke(winterSkywalkMode ? lociAccent.opacity(0.55) : Color.white.opacity(0.6), lineWidth: winterSkywalkMode ? 2.5 : 1)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                        
                        // Top Floating Husky Shuttle Live Pill
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("Husky Shuttle • 2 min away")
                                        .font(.caption.bold())
                                        .foregroundColor(.primary)
                                    Text("🚌")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.white.opacity(0.95))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
                            }
                            .padding(12)
                            
                            Spacer()
                            
                            // Bottom-Right Map Zoom & Indoor Floor Quick-Jump Controls
                            HStack(alignment: .bottom) {
                                if winterSkywalkMode {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(lociAccent)
                                            .frame(width: 8, height: 8)
                                        Text("Indoor Skywalk Path Active")
                                            .font(.caption2.bold())
                                            .foregroundColor(lociAccent)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.92))
                                    .clipShape(Capsule())
                                    .shadow(radius: 3)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 0) {
                                    Button(action: { zoomMap(factor: 0.65) }) {
                                        Image(systemName: "plus")
                                            .font(.subheadline.bold())
                                            .frame(width: 38, height: 38)
                                            .foregroundColor(.primary)
                                    }
                                    Divider()
                                        .frame(width: 26)
                                    Button(action: { zoomMap(factor: 1.45) }) {
                                        Image(systemName: "minus")
                                            .font(.subheadline.bold())
                                            .frame(width: 38, height: 38)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .background(Color.white.opacity(0.94))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .black.opacity(0.10), radius: 5, y: 2)
                            }
                            .padding(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 5. Bottom Building / Center / Winter Route Inspector Card
                    VStack(alignment: .leading, spacing: 10) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.28))
                            .frame(width: 38, height: 4)
                            .frame(maxWidth: .infinity)
                        
                        if winterSkywalkMode {
                            // Winter Skywalk Turn-by-Turn Card (Concept 3)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label(selectedBuilding.shortName, systemImage: "snowflake")
                                        .font(.caption.bold())
                                        .foregroundColor(lociAccent)
                                    Spacer()
                                    Text("\(selectedBuilding.walkMinutesIndoor) min indoor walk • Avoids snow 🚶‍♂️")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(lociAccent.opacity(0.14))
                                        .foregroundColor(lociAccent)
                                        .clipShape(Capsule())
                                }
                                
                                Text(selectedBuilding.skywalkRouteSummary)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(10)
                            .background(lociBackground.opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } else {
                            // Standard Center & Office Highlights (Concept 1)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedBuilding.primaryHighlight)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color.secondary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedBuilding.secondaryHighlight)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                    let contactCount = contactsInSelectedBuilding.isEmpty
                                        ? selectedBuilding.floors.flatMap(\.rooms).count
                                        : contactsInSelectedBuilding.count
                                    Text("\(selectedBuilding.name) • \(contactCount) Directory Contacts")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(selectedBuilding.isOpenNow ? "Open Now" : "Closed")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundColor(.green)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Action Row: Start Walking Route + Open Indoor Floor Plan (Concept 2)
                        HStack(spacing: 10) {
                            Button(action: {
                                openWalkingDirections(to: selectedBuilding)
                            }) {
                                HStack(spacing: 6) {
                                    Text("Start Walking Route (\(winterSkywalkMode ? selectedBuilding.walkMinutesIndoor : selectedBuilding.walkMinutesOutdoor) min)")
                                        .font(.subheadline.bold())
                                    Image(systemName: "paperplane.fill")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(lociAccent)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                            
                            Button(action: {
                                indoorTargetFloor = selectedBuilding.floors.last?.levelCode ?? "1F"
                                indoorTargetRoom = nil
                                showingIndoorMap = true
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "map.fill")
                                    Text("Floor Plan")
                                        .font(.caption.bold())
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(lociAccent.opacity(0.15))
                                .foregroundColor(lociAccent)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Live Interactive Map")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.body.bold())
                    .foregroundColor(lociAccent)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        indoorTargetFloor = selectedBuilding.floors.last?.levelCode ?? "1F"
                        showingIndoorMap = true
                    }) {
                        Label("Indoor Map", systemImage: "building.2.fill")
                            .foregroundColor(lociAccent)
                    }
                }
            }
            .sheet(isPresented: $showingIndoorMap) {
                MTUIndoorMapView(
                    building: selectedBuilding,
                    initialFloorCode: indoorTargetFloor,
                    initialRoom: indoorTargetRoom,
                    directoryContacts: directoryVM.contacts
                )
            }
            .task {
                if directoryVM.contacts.isEmpty {
                    await directoryVM.fetchContacts()
                }
                if let contact = focusedContact,
                   let match = MTUCampusData.matchBuilding(for: contact) {
                    focusOnBuilding(match.building)
                    indoorTargetFloor = match.floorCode
                    indoorTargetRoom = match.room
                    showingIndoorMap = true
                }
            }
        }
    }
    
    // MARK: - Map Helpers
    private func focusOnBuilding(_ building: MTUBuilding) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedBuilding = building
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
            let newLat = max(0.001, min(0.02, region.span.latitudeDelta * factor))
            let newLon = max(0.001, min(0.02, region.span.longitudeDelta * factor))
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

// MARK: - Xcode Previews for All 3 Concepts
#Preview("1. MTU 3D Campus Explorer") {
    MapView()
}

#Preview("2. Rekhi Hall Indoor Office Map") {
    MTUIndoorMapView(
        building: MTUCampusData.buildings[0],
        initialFloorCode: "3F"
    )
}
