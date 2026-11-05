import SwiftUI

struct MTUIndoorMapView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let building: MTUBuilding
    var initialFloorCode: String? = nil
    var initialRoom: MTUFloorRoom? = nil
    var directoryContacts: [Contact] = []
    
    @State private var selectedFloorCode: String = "3F"
    @State private var selectedRoom: MTUFloorRoom? = nil
    @State private var showAnimatedPath: Bool = true
    @State private var dashPhase: CGFloat = 0
    
    private var currentFloor: MTUFloorLevel {
        building.floors.first(where: { $0.levelCode == selectedFloorCode }) ?? building.floors[0]
    }
    
    private var floorContacts: [Contact] {
        directoryContacts.filter { contact in
            guard let office = contact.office else { return false }
            let matchesBuilding = building.matchingOfficePrefixes.contains { office.localizedCaseInsensitiveContains($0) }
            guard matchesBuilding else { return false }
            let floorDigit = String(selectedFloorCode.prefix(1))
            let roomNumbers = office.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if let num = roomNumbers.first {
                return num.hasPrefix(floorDigit)
            }
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    // Floor Subtitle Pill
                    HStack {
                        Image(systemName: "building.2.crop.circle.fill")
                            .foregroundColor(lociAccent)
                        Text(currentFloor.levelTitle)
                            .font(.subheadline.bold())
                            .foregroundColor(lociAccent)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAnimatedPath.toggle()
                            }
                        }) {
                            Label(showAnimatedPath ? "Path On" : "Path Off", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(showAnimatedPath ? lociAccent : Color.white)
                                .foregroundColor(showAnimatedPath ? .white : lociAccent)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    
                    // Interactive Architectural Floor Plan Canvas + Floor Switcher Pill
                    ZStack(alignment: .bottomTrailing) {
                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height
                            
                            ZStack {
                                // Outer Architectural Wing Shell
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.55))
                                    .frame(width: w * 0.80, height: h * 0.90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.primary.opacity(0.35), lineWidth: 2)
                                    )
                                    .position(x: w * 0.46, y: h * 0.50)
                                
                                // Central Corridor Spine
                                Rectangle()
                                    .fill(lociBackground.opacity(0.65))
                                    .frame(width: w * 0.12, height: h * 0.86)
                                    .position(x: w * currentFloor.hallwaySpineX, y: h * 0.50)
                                
                                // Left Wing Auxiliary Rooms (Labs / Lounges)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.85))
                                    .frame(width: w * 0.26, height: h * 0.22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primary.opacity(0.25), lineWidth: 1.2)
                                    )
                                    .position(x: w * 0.26, y: h * 0.48)
                                
                                // Elevator & Stairwell Core
                                VStack(spacing: 6) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "arrow.up.arrow.down.square.fill")
                                            .font(.title3)
                                            .foregroundColor(lociAccent)
                                        Text("Elevator")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: w * 0.16, height: h * 0.11)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.3), lineWidth: 1))
                                    
                                    VStack(spacing: 2) {
                                        Image(systemName: "stairs")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary.opacity(0.75))
                                        Text("Stairs")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: w * 0.16, height: h * 0.10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.3), lineWidth: 1))
                                }
                                .position(x: w * 0.24, y: h * 0.77)
                                
                                // Interactive Rooms on Current Floor
                                ForEach(currentFloor.rooms) { room in
                                    let isSelected = (selectedRoom?.id == room.id)
                                    let roomW = w * room.rect.width
                                    let roomH = h * room.rect.height
                                    let roomX = w * room.rect.midX
                                    let roomY = h * room.rect.midY
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                            selectedRoom = room
                                            showAnimatedPath = true
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(isSelected ? lociAccent.opacity(0.22) : Color.white.opacity(0.92))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .stroke(isSelected ? lociAccent : Color.primary.opacity(0.35), lineWidth: isSelected ? 2.5 : 1.2)
                                                )
                                                .shadow(color: isSelected ? lociAccent.opacity(0.25) : .clear, radius: 8, y: 3)
                                            
                                            VStack(spacing: 3) {
                                                if isSelected {
                                                    Image(systemName: "mappin.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(lociAccent)
                                                }
                                                Text(room.roomNumber)
                                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                                    .foregroundColor(isSelected ? lociAccent : .primary)
                                                Text(room.title)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: roomW, height: roomH)
                                    .position(x: roomX, y: roomY)
                                    .overlay(alignment: .top) {
                                        if isSelected {
                                            VStack(spacing: 1) {
                                                Text(building.shortName)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                Text(room.roomNumber.replacingOccurrences(of: "Rm ", with: ""))
                                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 5)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
                                            .position(x: roomX, y: max(20, roomY - roomH * 0.56))
                                        }
                                    }
                                }
                                
                                // Glowing Dotted Walking Path from Elevator/Stairs to Selected Room
                                if showAnimatedPath, let targetRoom = selectedRoom {
                                    let startPt = CGPoint(x: w * currentFloor.elevatorPoint.x, y: h * currentFloor.elevatorPoint.y)
                                    let spinePt1 = CGPoint(x: w * currentFloor.hallwaySpineX, y: h * currentFloor.elevatorPoint.y)
                                    let spinePt2 = CGPoint(x: w * currentFloor.hallwaySpineX, y: h * targetRoom.doorwayPoint.y)
                                    let endPt = CGPoint(x: w * targetRoom.doorwayPoint.x, y: h * targetRoom.doorwayPoint.y)
                                    
                                    Path { path in
                                        path.move(to: startPt)
                                        path.addLine(to: spinePt1)
                                        path.addLine(to: spinePt2)
                                        path.addLine(to: endPt)
                                    }
                                    .stroke(
                                        lociAccent.opacity(0.28),
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                                    )
                                    
                                    Path { path in
                                        path.move(to: startPt)
                                        path.addLine(to: spinePt1)
                                        path.addLine(to: spinePt2)
                                        path.addLine(to: endPt)
                                    }
                                    .stroke(
                                        lociAccent,
                                        style: StrokeStyle(
                                            lineWidth: 4.5,
                                            lineCap: .round,
                                            lineJoin: .round,
                                            dash: [6, 8],
                                            dashPhase: dashPhase
                                        )
                                    )
                                    .onAppear {
                                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                            dashPhase = -28
                                        }
                                    }
                                    
                                    // Destination Arrowhead Dot
                                    Circle()
                                        .fill(lociAccent)
                                        .frame(width: 12, height: 12)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .position(endPt)
                                }
                            }
                        }
                        
                        // Vertical Floor Switcher Pill (1F / 2F / 3F) on Right Side
                        VStack(spacing: 8) {
                            ForEach(building.floors) { floor in
                                let isSelected = (floor.levelCode == selectedFloorCode)
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        selectedFloorCode = floor.levelCode
                                        selectedRoom = floor.rooms.first
                                    }
                                }) {
                                    Text(floor.levelCode)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .frame(width: 44, height: 44)
                                        .background(isSelected ? lociAccent : Color.white.opacity(0.92))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .clipShape(Circle())
                                        .shadow(color: isSelected ? lociAccent.opacity(0.35) : .clear, radius: 4, y: 2)
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .padding(.trailing, 18)
                        .padding(.bottom, 16)
                    }
                    
                    // Bottom Inspector Card (Synced with Selected Room & Directory Contacts)
                    if let room = selectedRoom {
                        VStack(alignment: .leading, spacing: 12) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 42, height: 5)
                                .frame(maxWidth: .infinity)
                            
                            HStack(alignment: .center) {
                                Text(room.title)
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Text(room.roleBadge)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(lociAccent)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            Text(room.subtitle)
                                .font(.subheadline)
                                .foregroundColor(lociAccent)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Office Hours:")
                                    .font(.caption.bold())
                                Text(room.officeHours)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.secondary.opacity(0.10))
                            .clipShape(Capsule())
                            
                            // Additional Faculty on this Floor (if fetched from contacts.json)
                            if !floorContacts.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(floorContacts) { person in
                                            Button(action: {
                                                if let match = currentFloor.rooms.first(where: {
                                                    (person.office ?? "").localizedCaseInsensitiveContains($0.roomNumber.replacingOccurrences(of: "Rm ", with: ""))
                                                }) {
                                                    withAnimation { selectedRoom = match }
                                                }
                                            }) {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "person.circle.fill")
                                                        .foregroundColor(lociAccent)
                                                    Text("\(person.name) • \(person.office ?? "")")
                                                        .font(.caption2.bold())
                                                        .foregroundColor(.primary)
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(lociBackground.opacity(0.45))
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Action Buttons (Navigate Inside, Phone, Email)
                            HStack(spacing: 10) {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        showAnimatedPath = true
                                    }
                                }) {
                                    Label("Navigate Inside", systemImage: "location.fill")
                                        .font(.caption.bold())
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(lociAccent)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                
                                if let phoneURL = URL(string: "tel://\(room.phone)") {
                                    Link(destination: phoneURL) {
                                        Label(room.phone, systemImage: "phone.fill")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                            .background(lociAccent)
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                                
                                if let emailURL = URL(string: "mailto:\(room.email)") {
                                    Link(destination: emailURL) {
                                        Label("Email", systemImage: "envelope.fill")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                            .background(lociAccent)
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 10, y: -2)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    }
                }
            }
            .navigationTitle("\(building.shortName) • Indoor Map")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
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
            }
        }
    }
}

#Preview("Rekhi Hall Indoor Map") {
    MTUIndoorMapView(
        building: MTUCampusData.buildings[0],
        initialFloorCode: "3F"
    )
}
