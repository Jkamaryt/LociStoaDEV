import SwiftUI

// LociStoa redesign: the Map tab.
// This is the simple drawn campus map from the prototype. Buildings come from buildings.csv,
// where map_x / map_y place each one on a 1000 x 710 canvas.
// The team's live MapKit map (MapView.swift) opens from the "Open live map" button.

struct LSMapScreen: View {
    @EnvironmentObject var store: LSStore
    @State private var showingLiveMap = false

    static let layerColors: [String: Color] = [
        "Academic": Color(lsHex: 0x1F4E79),
        "Services": Color(lsHex: 0x9C2F5B),
        "Housing": Color(lsHex: 0x8A5A00),
        "Athletics": Color(lsHex: 0x2E6B3F),
    ]

    private var currentBuilding: LSBuilding? {
        guard let id = store.building else { return nil }
        return store.data.buildings.first { $0.id == id }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                LSTitle(text: "Map")

                LSChipRow {
                    ForEach(["All", "Academic", "Services", "Housing", "Athletics"], id: \.self) { name in
                        LSChip(label: name,
                               on: store.layer == name,
                               dot: LSMapScreen.layerColors[name] ?? Color(lsHex: 0x8C939B)) {
                            store.layer = name
                        }
                    }
                }

                LSCampusCanvas()
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(store.p.strong, lineWidth: 1)
                    )

                Text("Drag the map to look around. Simplified layout, not to scale.")
                    .font(.ls(13))
                    .foregroundStyle(store.p.sub)

                if let building = currentBuilding {
                    LSCard(padding: 18) {
                        Text(building.name).font(.ls(20, .bold))
                        Text(building.layer)
                            .font(.ls(13.5, .semibold))
                            .foregroundStyle(store.p.sub)
                            .padding(.top, 2)
                        Text(building.inside)
                            .font(.ls(14))
                            .padding(.top, 2)

                        HStack(spacing: 8) {
                            ForEach(["1F", "2F", "3F"], id: \.self) { level in
                                let on = store.floor == level
                                Button {
                                    store.floor = level
                                } label: {
                                    Text(level)
                                        .font(.ls(15, .bold))
                                        .foregroundStyle(on ? Color.white : store.p.ink)
                                        .frame(width: 64, height: 44)
                                        .background(on ? store.p.ink : Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(on ? store.p.ink : store.p.strong, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(LSPressStyle())
                                .accessibilityAddTraits(on ? .isSelected : [])
                            }
                        }
                        .padding(.top, 12)

                        Text("Floor plan image for \(store.floor) goes here")
                            .font(.ls(13.5, .semibold))
                            .foregroundStyle(store.p.sub)
                            .frame(maxWidth: .infinity)
                            .frame(height: 76)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(store.p.check, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            )
                            .padding(.top, 12)
                    }
                } else {
                    LSCard(padding: 18) {
                        Text("Tap a building").font(.ls(15, .bold))
                        Text("You'll see its floors and what's inside.")
                            .font(.ls(13.5))
                            .foregroundStyle(store.p.sub)
                            .padding(.top, 4)
                    }
                }

                LSBigButton(title: "Open live map", icon: "location.fill", soft: true) {
                    showingLiveMap = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingLiveMap) {
            MapView()
        }
    }
}

/// The drawn map: water, road, and one button per building. It scrolls in both directions.
struct LSCampusCanvas: View {
    @EnvironmentObject var store: LSStore

    private let mapWidth: CGFloat = 1000
    private let mapHeight: CGFloat = 710
    private let grass = Color(lsHex: 0xDDEBD6)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    Color(lsHex: 0xEEF2EC)

                    // Green patches
                    Ellipse().fill(grass).frame(width: 300, height: 110).position(x: 330, y: 120)
                    Ellipse().fill(grass).frame(width: 180, height: 100).position(x: 640, y: 400)
                    Ellipse().fill(grass).frame(width: 340, height: 120).position(x: 470, y: 560)
                    Ellipse().fill(grass).frame(width: 300, height: 90).position(x: 860, y: 660)
                    Ellipse().fill(grass).frame(width: 220, height: 140).position(x: 110, y: 470)

                    // Keweenaw Waterway
                    Path { path in
                        path.move(to: CGPoint(x: 240, y: 0))
                        path.addLine(to: CGPoint(x: 280, y: 48))
                        path.addLine(to: CGPoint(x: 475, y: 55))
                        path.addLine(to: CGPoint(x: 505, y: 80))
                        path.addLine(to: CGPoint(x: 645, y: 125))
                        path.addLine(to: CGPoint(x: 675, y: 150))
                        path.addLine(to: CGPoint(x: 800, y: 235))
                        path.addLine(to: CGPoint(x: 1000, y: 345))
                        path.addLine(to: CGPoint(x: 1000, y: 0))
                        path.closeSubpath()
                    }
                    .fill(Color(lsHex: 0xA9D3EA))

                    // US-41: a gray line with a slightly thinner white line on top
                    roadPath.stroke(Color(lsHex: 0xC3CAD2), style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                    roadPath.stroke(Color.white, style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))

                    // Labels
                    Text("KEWEENAW WATERWAY")
                        .font(.ls(14, .bold))
                        .tracking(1.5)
                        .foregroundStyle(Color(lsHex: 0x22607F))
                        .fixedSize()
                        .position(x: 790, y: 75)
                    Text("US-41 · TOWNSEND DR")
                        .font(.ls(11, .bold))
                        .foregroundStyle(Color(lsHex: 0x4B5560))
                        .fixedSize()
                        .rotationEffect(.degrees(7))
                        .position(x: 515, y: 484)
                    Text("US-41 · COLLEGE AVE")
                        .font(.ls(11, .bold))
                        .foregroundStyle(Color(lsHex: 0x4B5560))
                        .fixedSize()
                        .rotationEffect(.degrees(41))
                        .position(x: 108, y: 258)
                    VStack(spacing: 0) {
                        Image(systemName: "location.north.fill").font(.ls(18))
                        Text("N").font(.ls(12, .bold))
                    }
                    .foregroundStyle(Color(lsHex: 0x4B5560))
                    .position(x: 48, y: 56)

                    // An invisible marker in the middle of campus, where the map starts out
                    Color.clear
                        .frame(width: 1, height: 1)
                        .id("campus-center")
                        .position(x: 470, y: 330)

                    // Buildings
                    ForEach(store.data.buildings) { building in
                        // .id comes before .position so "scroll to this building" aims at the button itself
                        LSBuildingButton(building: building)
                            .id(building.id)
                            .position(x: building.x, y: building.y)
                    }
                }
                .frame(width: mapWidth, height: mapHeight)
            }
            .task {
                // Center on the picked building, or on the middle of campus.
                // The short wait lets the map finish laying out first.
                try? await Task.sleep(nanoseconds: 80_000_000)
                proxy.scrollTo(store.building ?? "campus-center", anchor: .center)
            }
            .onChange(of: store.building) {
                if let id = store.building {
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    private var roadPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 150))
            path.addLine(to: CGPoint(x: 150, y: 280))
            path.addQuadCurve(to: CGPoint(x: 260, y: 395), control: CGPoint(x: 205, y: 340))
            path.addQuadCurve(to: CGPoint(x: 415, y: 465), control: CGPoint(x: 330, y: 452))
            path.addLine(to: CGPoint(x: 600, y: 488))
            path.addLine(to: CGPoint(x: 725, y: 510))
            path.addLine(to: CGPoint(x: 1000, y: 570))
        }
    }
}

struct LSBuildingButton: View {
    @EnvironmentObject var store: LSStore
    let building: LSBuilding

    var body: some View {
        let on = store.building == building.id
        let inLayer = store.layer == "All" || store.layer == building.layer
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)

        Button {
            store.building = building.id
            store.floor = "1F"
        } label: {
            Text(building.short)
                .font(.ls(11.5, .bold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 4)
                .frame(width: building.w, height: building.h)
                .background(LSMapScreen.layerColors[building.layer] ?? Color.gray)
                .clipShape(shape)
                .overlay(shape.stroke(Color.white, lineWidth: on ? 3 : 0))
                .shadow(color: Color.black.opacity(on ? 0.6 : 0.3), radius: on ? 4 : 1, x: 0, y: 1)
        }
        .buttonStyle(LSPressStyle())
        .opacity(inLayer ? 1.0 : 0.25)
        .accessibilityLabel(building.name)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
