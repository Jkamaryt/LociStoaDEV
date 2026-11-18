import SwiftUI

struct MTUIndoorMapView: View {
    @Environment(\.dismiss) private var dismiss
    
    let building: MTUBuilding
    var initialFloorCode: String? = nil
    var initialRoom: MTUFloorRoom? = nil
    var directoryContacts: [Contact] = []
    var onBackToCampusMap: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil
    
    @State private var selectedFloorCode: String = "1F"
    @State private var selectedRoom: MTUFloorRoom? = nil
    @State private var selectedPortalID: String = "elevator"
    @State private var showAnimatedPath: Bool = true
    @State private var showTurnByTurnSteps: Bool = false
    
    private var currentFloor: MTUFloorLevel {
        building.floors.first(where: { $0.levelCode == selectedFloorCode }) ?? building.floors[0]
    }
    
    private var availablePortals: [MTUFloorEntryPortal] {
        currentFloor.entryPortals(for: building)
    }
    
    private var activePortal: MTUFloorEntryPortal {
        availablePortals.first(where: { $0.id == selectedPortalID }) ?? availablePortals[0]
    }
    
    private var floorContacts: [Contact] {
        directoryContacts.filter { contact in
            guard let office = contact.office else { return false }
            let matchesBuilding = building.matchingOfficePrefixes.contains { office.localizedCaseInsensitiveContains($0) }
            guard matchesBuilding else { return false }
            if selectedFloorCode == "GF" {
                return office.localizedCaseInsensitiveContains("G0")
            }
            let floorDigit = String(selectedFloorCode.prefix(1))
            let roomNumbers = office.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if let num = roomNumbers.first {
                return num.hasPrefix(floorDigit)
            }
            return selectedFloorCode == "1F"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // 1. Top Building & Floor Context Bar + Route Start Selector
                    headerAndPortalBar
                    
                    // 2. Interactive Architectural Floor Plan Canvas + Floor Switcher
                    ZStack(alignment: .bottomTrailing) {
                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height
                            
                            ZStack {
                                // A. Architectural Blueprint Shell, Corridors, Landmarks & Orientation Markers
                                architecturalBlueprintLayer(w: w, h: h)
                                    .allowsHitTesting(false)
                                
                                // B. Interactive Rooms on Current Floor
                                ForEach(currentFloor.rooms) { room in
                                    roomButton(for: room, w: w, h: h)
                                }
                                
                                // C. Glowing Multi-Segment Walking Path from Selected Portal to Room Doorway
                                if showAnimatedPath, let targetRoom = selectedRoom {
                                    walkingPathOverlay(to: targetRoom, w: w, h: h)
                                        .allowsHitTesting(false)
                                }
                                
                                // D. Selected Room Floating Callout Pill
                                if let room = selectedRoom {
                                    selectedRoomCallout(for: room, w: w, h: h)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // Vertical Floor Switcher Pill on Right Side
                        floorSwitcherColumn
                    }
                    
                    // 3. Horizontal Quick-Jump Room Strip + Visual Category Legend
                    floorRoomStrip
                    
                    // 4. Bottom Inspector Card with Relative Spatial Reference & Turn-by-Turn Route
                    if let room = selectedRoom {
                        roomInspectorCard(for: room)
                    }
                }
            }
            .navigationTitle("\(building.shortName) • Bldg #\(building.buildingNumber)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if let onBackToCampusMap {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: onBackToCampusMap) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Campus Map")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(lociAccent)
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        if let onClose {
                            onClose()
                        } else {
                            dismiss()
                        }
                    }
                    .font(.body.bold())
                    .foregroundColor(lociAccent)
                }
            }
            .onAppear {
                let startFloor = initialFloorCode ?? building.floors.last?.levelCode ?? "1F"
                selectedFloorCode = startFloor
                if let initialRoom = initialRoom {
                    selectedRoom = initialRoom
                } else if let floor = building.floors.first(where: { $0.levelCode == startFloor }) ?? building.floors.first {
                    selectedRoom = floor.rooms.first
                }
                selectedPortalID = availablePortals.first?.id ?? "elevator"
            }
        }
    }
    
    // MARK: - 1. Header & Route Entry Portal Selector
    private var headerAndPortalBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "building.2.crop.circle.fill")
                    .foregroundColor(lociAccent)
                Text(currentFloor.levelTitle)
                    .font(.caption.bold())
                    .foregroundColor(lociAccent)
                    .lineLimit(1)
                Spacer()
                if let room = selectedRoom {
                    let summary = currentFloor.routeSummary(from: activePortal, to: room, building: building)
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(summary.distanceFeet) ft • ~\(summary.seconds)s")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background( Color.white.opacity(0.9))
                    .foregroundColor(lociAccent)
                    .clipShape(Capsule())
                }
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showAnimatedPath.toggle()
                    }
                }) {
                    Label(showAnimatedPath ? "Route On" : "Route Off", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        .font(.caption2.bold())
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(showAnimatedPath ? lociAccent : Color.white)
                        .foregroundColor(showAnimatedPath ? .white : lociAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            
            // Route Start Point ("Route From:") + Room Color Legend
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Text("Route From:")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    ForEach(availablePortals) { portal in
                        let isSelected = (activePortal.id == portal.id)
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                                selectedPortalID = portal.id
                                showAnimatedPath = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: portal.icon)
                                    .font(.system(size: 10, weight: .bold))
                                Text(portal.shortLabel)
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(isSelected ? lociAccent : Color.white.opacity(0.85))
                            .foregroundColor(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                        .frame(height: 14)
                        .padding(.horizontal, 2)
                    
                    // Visual Marker Key
                    ForEach([MTURoomKind.departmentHub, .facultyOffice, .learningLab, .studentSupport]) { kind in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(kind.color)
                                .frame(width: 7, height: 7)
                            Text(kind.rawValue)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.65))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. Architectural Blueprint Layer (Orientation, Corridors & Landmarks)
    private func architecturalBlueprintLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Outer Architectural Building Footprint Shell
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .frame(width: w * 0.84, height: h * 0.88)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.32), lineWidth: 2)
                )
                .position(x: w * 0.46, y: h * 0.50)
            
            // Subtle Wing Zone Backgrounds
            // West Wing Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.45))
                .frame(width: w * 0.26, height: h * 0.82)
                .position(x: w * 0.205, y: h * 0.50)
            
            // East Wing Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.45))
                .frame(width: w * 0.28, height: h * 0.82)
                .position(x: w * 0.725, y: h * 0.50)
            
            // Multi-Corridor Hallway Network
            // 1) West North-South Corridor
            RoundedRectangle(cornerRadius: 6)
                .fill(lociBackground.opacity(0.75))
                .frame(width: w * 0.048, height: h * 0.80)
                .position(x: w * currentFloor.westHallwaySpineX, y: h * 0.50)
            
            // 2) East North-South Main Corridor
            RoundedRectangle(cornerRadius: 6)
                .fill(lociBackground.opacity(0.75))
                .frame(width: w * 0.052, height: h * 0.80)
                .position(x: w * currentFloor.hallwaySpineX, y: h * 0.50)
            
            // 3) North Cross-Corridor
            RoundedRectangle(cornerRadius: 6)
                .fill(lociBackground.opacity(0.75))
                .frame(width: w * 0.24, height: h * 0.045)
                .position(x: w * 0.46, y: h * currentFloor.northCrossHallY)
            
            // 4) South Lobby Cross-Corridor
            RoundedRectangle(cornerRadius: 6)
                .fill(lociBackground.opacity(0.75))
                .frame(width: w * 0.24, height: h * 0.055)
                .position(x: w * 0.46, y: h * currentFloor.southCrossHallY)
            
            // Skywalk / West Connector Corridor (if applicable)
            if building.hasSkywalkAccess && (currentFloor.levelCode == "1F" || currentFloor.levelCode == "2F") {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: w * 0.28, height: h * 0.045)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.blue.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    )
                    .position(x: w * 0.22, y: h * 0.50)
            }
            
            // Wing Header Labels inside Shell
            Text("WEST WING")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .tracking(0.8)
                .foregroundColor(.secondary.opacity(0.7))
                .position(x: w * 0.20, y: h * 0.08)
            
            Text("CENTRAL CORE")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundColor(.secondary.opacity(0.7))
                .position(x: w * 0.455, y: h * 0.08)
            
            Text("EAST WING")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .tracking(0.8)
                .foregroundColor(.secondary.opacity(0.7))
                .position(x: w * 0.72, y: h * 0.08)
            
            // Exterior Wall Reference Orientation Pills (North, South, West, East)
            // NORTH Reference Banner
            HStack(spacing: 4) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(lociAccent)
                Text("▲ NORTH: \(building.northReference)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.92))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(lociAccent.opacity(0.3), lineWidth: 1))
            .position(x: w * 0.46, y: h * 0.03)
            
            // SOUTH Reference Banner
            HStack(spacing: 4) {
                Image(systemName: "road.lanes")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(lociAccent)
                Text("▼ SOUTH: \(building.southReference)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.92))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(lociAccent.opacity(0.3), lineWidth: 1))
            .position(x: w * 0.46, y: h * 0.97)
            
            // WEST & EAST Reference Badges
            HStack(spacing: 3) {
                Text("◀ W: \(building.westReference)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.85))
            .clipShape(Capsule())
            .position(x: w * 0.18, y: h * 0.925)
            
            HStack(spacing: 3) {
                Text("E: \(building.eastReference) ▶")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.85))
            .clipShape(Capsule())
            .position(x: w * 0.72, y: h * 0.925)
            
            // Compass Rose Badge (Top-Left)
            VStack(spacing: 1) {
                Text("N")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(lociAccent)
                Image(systemName: "location.north.line.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(lociAccent)
                Text("W • E")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 32, height: 36)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.15), lineWidth: 1))
            .position(x: w * 0.09, y: h * 0.04)
            
            // Scale Bar (Bottom-Left)
            VStack(spacing: 1) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color.primary.opacity(0.65)).frame(width: 1, height: 4)
                    Rectangle().fill(Color.primary.opacity(0.65)).frame(width: 24, height: 1.5)
                    Rectangle().fill(Color.primary.opacity(0.65)).frame(width: 1, height: 4)
                }
                Text("50 ft")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.85))
            .cornerRadius(4)
            .position(x: w * 0.08, y: h * 0.965)
            
            // Central Service Core Landmarks (Elevator, North/South Stairs, Restrooms, Water, Doors, Skywalk)
            ForEach(currentFloor.landmarks(for: building)) { landmark in
                let isPortalOrigin = (activePortal.point == landmark.point)
                VStack(spacing: 1) {
                    Image(systemName: landmark.kind.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isPortalOrigin ? .white : landmark.kind.tint)
                    Text(landmark.title)
                        .font(.system(size: 7.5, weight: .bold, design: .rounded))
                        .foregroundColor(isPortalOrigin ? .white : .primary.opacity(0.85))
                        .lineLimit(1)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .frame(minWidth: w * 0.115)
                .background(isPortalOrigin ? lociAccent : Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(isPortalOrigin ? lociAccent : landmark.kind.tint.opacity(0.45), lineWidth: isPortalOrigin ? 2 : 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                .position(x: w * landmark.point.x, y: h * landmark.point.y)
            }
        }
    }
    
    // MARK: - 3. Interactive Room Card & Doorway Marker
    private func roomButton(for room: MTUFloorRoom, w: CGFloat, h: CGFloat) -> some View {
        let isSelected = (selectedRoom?.id == room.id)
        let roomW = w * room.rect.width
        let roomH = h * room.rect.height
        let roomX = w * room.rect.midX
        let roomY = h * room.rect.midY
        let isCompact = (roomH < 44)
        let kindColor = room.kind.color
        
        return ZStack {
            // Doorway Threshold Marker on Corridor Edge
            Circle()
                .fill(isSelected ? lociAccent : kindColor.opacity(0.65))
                .frame(width: isSelected ? 8 : 5, height: isSelected ? 8 : 5)
                .position(x: w * room.doorwayPoint.x, y: h * room.doorwayPoint.y)
                .allowsHitTesting(false)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                    selectedRoom = room
                    showAnimatedPath = true
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: isCompact ? 7 : 10, style: .continuous)
                        .fill(isSelected ? lociAccent.opacity(0.20) : Color.white.opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: isCompact ? 7 : 10, style: .continuous)
                                .stroke(isSelected ? lociAccent : kindColor.opacity(0.55), lineWidth: isSelected ? 2.4 : 1.2)
                        )
                        .shadow(color: isSelected ? lociAccent.opacity(0.28) : .black.opacity(0.03), radius: isSelected ? 6 : 2, y: 1)
                    
                    // Left color accent bar inside room card
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isSelected ? lociAccent : kindColor)
                            .frame(width: 3.5)
                            .padding(.vertical, isCompact ? 3 : 5)
                            .padding(.leading, 3)
                        Spacer()
                    }
                    
                    if isCompact {
                        // Compact layout for high-density floors (e.g. Rekhi 2F with 13 rooms)
                        HStack(spacing: 4) {
                            Text(room.roomNumber.replacingOccurrences(of: "Rm ", with: ""))
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundColor(isSelected ? lociAccent : kindColor)
                            Text(room.title)
                                .font(.system(size: 9.5, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.leading, 8)
                        .padding(.trailing, 4)
                    } else {
                        // Standard multi-line layout
                        VStack(spacing: 2) {
                            HStack(spacing: 3) {
                                Image(systemName: isSelected ? "mappin.circle.fill" : room.kind.icon)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isSelected ? lociAccent : kindColor)
                                Text(room.roomNumber)
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(isSelected ? lociAccent : .primary)
                            }
                            Text(room.title)
                                .font(.system(size: 9.5, weight: .semibold))
                                .foregroundColor(.primary.opacity(0.9))
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                            if roomH > 62 {
                                Text(room.roleBadge)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(kindColor)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.leading, 4)
                    }
                }
                .frame(width: roomW, height: roomH)
                .contentShape(RoundedRectangle(cornerRadius: isCompact ? 7 : 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(width: roomW, height: roomH)
            .position(x: roomX, y: roomY)
        }
    }
    
    // MARK: - 4. Multi-Waypoint Animated Walking Path Overlay
    private func walkingPathOverlay(to targetRoom: MTUFloorRoom, w: CGFloat, h: CGFloat) -> some View {
        let waypoints = currentFloor.routeWaypoints(from: activePortal, to: targetRoom)
        let scaledPoints = waypoints.map { CGPoint(x: w * $0.x, y: h * $0.y) }
        let startPt = scaledPoints.first ?? .zero
        let endPt = scaledPoints.last ?? .zero
        
        return TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = -CGFloat((elapsed.truncatingRemainder(dividingBy: 1.2)) / 1.2) * 28.0
            
            ZStack {
                // Outer Glow Path
                Path { path in
                    guard let first = scaledPoints.first else { return }
                    path.move(to: first)
                    for pt in scaledPoints.dropFirst() {
                        path.addLine(to: pt)
                    }
                }
                .stroke(
                    lociAccent.opacity(0.26),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round)
                )
                
                // Animated Dashed Core Path
                Path { path in
                    guard let first = scaledPoints.first else { return }
                    path.move(to: first)
                    for pt in scaledPoints.dropFirst() {
                        path.addLine(to: pt)
                    }
                }
                .stroke(
                    lociAccent,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [6, 7],
                        dashPhase: phase
                    )
                )
                
                // Origin Marker Badge ("START")
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .position(startPt)
                
                // Destination Doorway Pin
                Circle()
                    .fill(lociAccent)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: lociAccent.opacity(0.5), radius: 3)
                    .position(endPt)
            }
        }
    }
    
    // MARK: - 5. Selected Room Callout Pill
    private func selectedRoomCallout(for room: MTUFloorRoom, w: CGFloat, h: CGFloat) -> some View {
        let roomH = h * room.rect.height
        let roomX = w * room.rect.midX
        let roomY = h * room.rect.midY
        
        return HStack(spacing: 4) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(lociAccent)
            Text("\(room.roomNumber) • \(room.wingName)")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(lociAccent.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
        .position(x: roomX, y: max(18, roomY - roomH * 0.56))
    }
    
    // MARK: - 6. Floor Switcher Column
    private var floorSwitcherColumn: some View {
        let isManyFloors = building.floors.count > 4
        let btnSize: CGFloat = isManyFloors ? 34 : 42
        
        return VStack(spacing: isManyFloors ? 5 : 8) {
            ForEach(building.floors.reversed()) { floor in
                let isSelected = (floor.levelCode == selectedFloorCode)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedFloorCode = floor.levelCode
                        selectedRoom = floor.rooms.first
                    }
                }) {
                    Text(floor.levelCode)
                        .font(.system(size: isManyFloors ? 11 : 13, weight: .bold, design: .rounded))
                        .frame(width: btnSize, height: btnSize)
                        .background(isSelected ? lociAccent : Color.white.opacity(0.92))
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Circle())
                        .shadow(color: isSelected ? lociAccent.opacity(0.35) : .clear, radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.88))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.trailing, 12)
        .padding(.bottom, 16)
    }
    
    // MARK: - 7. Floor-Wide Room Quick-Jump Strip
    private var floorRoomStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(currentFloor.rooms) { room in
                    let isSelected = (selectedRoom?.id == room.id)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                            selectedRoom = room
                            showAnimatedPath = true
                        }
                    }) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(isSelected ? Color.white : room.kind.color)
                                .frame(width: 7, height: 7)
                            Text(room.roomNumber)
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                            Text("•")
                                .opacity(0.5)
                            Text(room.title)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? lociAccent : Color.white.opacity(0.9))
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(room.kind.color.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 8. Bottom Room Inspector Card with Relative Reference & Turn-by-Turn Steps
    private func roomInspectorCard(for room: MTUFloorRoom) -> some View {
        let routeInfo = currentFloor.routeSummary(from: activePortal, to: room, building: building)
        
        return VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(room.roomNumber) • \(room.title)")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(room.subtitle)
                        .font(.caption)
                        .foregroundColor(lociAccent)
                        .lineLimit(1)
                }
                Spacer()
                Text(room.roleBadge)
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(room.kind.color)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            // Spatial Reference & Office Hours Row
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "compass.drawing")
                        .font(.caption2)
                        .foregroundColor(lociAccent)
                    Text(room.relativeReferenceText)
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(lociBackground.opacity(0.45))
                .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.green)
                        .font(.caption2)
                    Text(room.officeHours)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.secondary.opacity(0.10))
                .clipShape(Capsule())
            }
            
            // Expandable Turn-by-Turn Indoor Navigation Steps
            if showTurnByTurnSteps {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(routeInfo.steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(idx + 1)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .frame(width: 16, height: 16)
                                .background(lociAccent)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text(step)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(lociBackground.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Additional Directory Contacts on this Floor (if multiple people share the floor/suite)
            if !floorContacts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(floorContacts) { person in
                            Button(action: {
                                if let match = MTUCampusData.matchBuilding(for: person)?.room {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                                        selectedRoom = match
                                        showAnimatedPath = true
                                    }
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(lociAccent)
                                        .font(.caption2)
                                    Text("\(person.name) (\(person.office?.replacingOccurrences(of: building.name + " ", with: "").replacingOccurrences(of: building.shortName + " ", with: "") ?? ""))")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(lociBackground.opacity(0.4))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Action Buttons (Turn-by-Turn Steps, Phone, Email)
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showAnimatedPath = true
                        showTurnByTurnSteps.toggle()
                    }
                }) {
                    Label(
                        showTurnByTurnSteps ? "Hide Steps (\(routeInfo.distanceFeet) ft)" : "Indoor Steps (\(routeInfo.distanceFeet) ft)",
                        systemImage: "point.topleft.down.curvedto.point.bottomright.up"
                    )
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(lociAccent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                
                if let phoneURL = URL(string: "tel://\(room.phone)") {
                    Link(destination: phoneURL) {
                        Label(room.phone, systemImage: "phone.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 11)
                            .padding(.vertical, 10)
                            .background(lociAccent.opacity(0.15))
                            .foregroundColor(lociAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                }
                
                if let emailURL = URL(string: "mailto:\(room.email)") {
                    Link(destination: emailURL) {
                        Label("Email", systemImage: "envelope.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 11)
                            .padding(.vertical, 10)
                            .background(lociAccent.opacity(0.15))
                            .foregroundColor(lociAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}

#Preview("Rekhi Hall Indoor Map") {
    MTUIndoorMapView(
        building: MTUCampusData.buildings[0],
        initialFloorCode: "3F"
    )
}
