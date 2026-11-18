import SwiftUI
import MapKit

// MARK: - Category Filter Model
enum MTULocationCategory: String, CaseIterable, Identifiable {
    case all = "All Campus"
    case learningCenters = "Learning Centers"
    case facultyOffices = "Faculty Offices"
    case studentSupport = "Student Support"
    case transitDining = "Dining & Shuttle"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "map.fill"
        case .learningCenters: return "graduationcap.fill"
        case .facultyOffices: return "person.text.rectangle.fill"
        case .studentSupport: return "building.columns.fill"
        case .transitDining: return "bus.fill"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .all: return Color(red: 0.45, green: 0.31, blue: 0.76)
        case .learningCenters: return Color(red: 0.88, green: 0.46, blue: 0.12)
        case .facultyOffices: return Color(red: 0.45, green: 0.31, blue: 0.76)
        case .studentSupport: return Color(red: 0.13, green: 0.58, blue: 0.53)
        case .transitDining: return Color(red: 0.18, green: 0.44, blue: 0.82)
        }
    }
}

// MARK: - Room Differentiation & Visual Marker Types
enum MTURoomKind: String, CaseIterable, Identifiable {
    case facultyOffice = "Faculty Office"
    case departmentHub = "Dept / Advising"
    case learningLab = "Lab / Classroom"
    case studentSupport = "Student Service"
    case campusAmenity = "Commons / Event"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .facultyOffice: return "person.text.rectangle.fill"
        case .departmentHub: return "building.columns.fill"
        case .learningLab: return "desktopcomputer"
        case .studentSupport: return "person.crop.circle.badge.checkmark"
        case .campusAmenity: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .facultyOffice: return Color(red: 0.45, green: 0.31, blue: 0.76)   // Purple
        case .departmentHub: return Color(red: 0.12, green: 0.48, blue: 0.84)   // Blue
        case .learningLab: return Color(red: 0.88, green: 0.46, blue: 0.10)     // Amber
        case .studentSupport: return Color(red: 0.12, green: 0.60, blue: 0.45)  // Emerald
        case .campusAmenity: return Color(red: 0.78, green: 0.26, blue: 0.54)   // Magenta
        }
    }
}

// MARK: - Indoor Entry Portals & Reference Landmarks
struct MTUFloorEntryPortal: Identifiable, Hashable {
    let id: String
    let label: String
    let shortLabel: String
    let icon: String
    let point: CGPoint
    let referenceNote: String
}

enum MTUFloorLandmarkKind: String, Hashable {
    case elevator = "Elevator"
    case stairs = "Stairs"
    case restroom = "Restrooms"
    case water = "Water Station"
    case skywalk = "Skywalk / Tunnel"
    case entrance = "Main Entrance"
    case lounge = "Study Lounge"
    
    var icon: String {
        switch self {
        case .elevator: return "arrow.up.arrow.down.square.fill"
        case .stairs: return "stairs"
        case .restroom: return "figure.dress.line.vertical.figure"
        case .water: return "drop.fill"
        case .skywalk: return "snowflake"
        case .entrance: return "door.left.hand.open"
        case .lounge: return "sofa.fill"
        }
    }
    
    var tint: Color {
        switch self {
        case .elevator: return Color(red: 0.45, green: 0.31, blue: 0.76)
        case .stairs: return Color(red: 0.35, green: 0.38, blue: 0.46)
        case .restroom: return Color(red: 0.16, green: 0.52, blue: 0.78)
        case .water: return Color(red: 0.10, green: 0.65, blue: 0.85)
        case .skywalk: return Color(red: 0.22, green: 0.48, blue: 0.92)
        case .entrance: return Color(red: 0.14, green: 0.62, blue: 0.38)
        case .lounge: return Color(red: 0.85, green: 0.48, blue: 0.16)
        }
    }
}

struct MTUFloorLandmark: Identifiable, Hashable {
    let id: String
    let title: String
    let kind: MTUFloorLandmarkKind
    let point: CGPoint
}

// MARK: - Indoor Floor Plan Models
struct MTUFloorRoom: Identifiable, Hashable {
    let id: String
    let roomNumber: String
    let title: String
    let subtitle: String
    let roleBadge: String
    let officeHours: String
    let phone: String
    let email: String
    /// Normalized rectangle (0.0 to 1.0) within the floor plan canvas
    let rect: CGRect
    /// Normalized entry point (0.0 to 1.0) in the hallway for indoor path routing
    let doorwayPoint: CGPoint
    
    /// Inferred visual room kind for color-coded markers and legends
    var kind: MTURoomKind {
        let lowerBadge = roleBadge.lowercased()
        let lowerTitle = title.lowercased()
        let lowerSub = subtitle.lowercased()
        if lowerBadge.contains("advisor") || lowerBadge.contains("chair") || lowerBadge.contains("dean") || lowerBadge.contains("director") || lowerTitle.contains("dept") {
            return .departmentHub
        } else if lowerBadge.contains("learning") || lowerBadge.contains("classroom") || lowerBadge.contains("lab") || lowerBadge.contains("makerspace") || lowerBadge.contains("study") || lowerBadge.contains("quiet") || lowerSub.contains("lab") || lowerSub.contains("classroom") {
            return .learningLab
        } else if lowerBadge.contains("support") || lowerBadge.contains("financial") || lowerBadge.contains("career") || lowerBadge.contains("health") || lowerBadge.contains("it ") || lowerBadge.contains("parking") || lowerBadge.contains("international") || lowerBadge.contains("grad") || lowerBadge.contains("housing") || lowerBadge.contains("safety") || lowerBadge.contains("admissions") || lowerBadge.contains("hr") || lowerBadge.contains("disability") || lowerBadge.contains("registrar") {
            return .studentSupport
        } else if lowerBadge.contains("winter") || lowerBadge.contains("event") || lowerBadge.contains("dining") || lowerBadge.contains("store") || lowerBadge.contains("athletics") || lowerBadge.contains("library") {
            return .campusAmenity
        } else {
            return .facultyOffice
        }
    }
    
    /// Wing position label for spatial orientation
    var wingName: String {
        if rect.midX < 0.36 {
            return "West Wing"
        } else if rect.midX > 0.55 {
            return "East Wing"
        } else {
            return "Central Core"
        }
    }
    
    /// Relative landmark description so users know where this room is in reference to other features
    var relativeReferenceText: String {
        let verticalZone: String
        if rect.midY < 0.30 {
            verticalZone = "North End (near North Stairwell)"
        } else if rect.midY < 0.62 {
            verticalZone = "Mid-Corridor (across from Central Core & Restrooms)"
        } else {
            verticalZone = "South End (near Main Elevator & Lobby)"
        }
        return "\(wingName) • \(verticalZone)"
    }
}

struct MTUFloorLevel: Identifiable, Hashable {
    var id: String { levelCode }
    let levelCode: String       // "GF", "1F", "2F", "3F", "4F", "5F", "6F", "7F"
    let levelTitle: String      // e.g., "3rd Floor • Computer Science Faculty"
    let elevatorPoint: CGPoint  // Normalized start point for primary elevator
    let hallwaySpineX: CGFloat  // Normalized East hallway X coordinate
    let rooms: [MTUFloorRoom]
    
    /// West hallway spine X coordinate for dual-wing floor layouts
    var westHallwaySpineX: CGFloat { 0.36 }
    /// North cross-corridor Y coordinate
    var northCrossHallY: CGFloat { 0.22 }
    /// South cross-corridor Y coordinate
    var southCrossHallY: CGFloat { 0.78 }
    
    /// Selectable starting portals on this floor
    func entryPortals(for building: MTUBuilding) -> [MTUFloorEntryPortal] {
        var portals: [MTUFloorEntryPortal] = [
            MTUFloorEntryPortal(
                id: "elevator",
                label: "Central Elevator",
                shortLabel: "Elevator",
                icon: "arrow.up.arrow.down.square.fill",
                point: elevatorPoint,
                referenceNote: "South-Central Core Elevator Bank"
            ),
            MTUFloorEntryPortal(
                id: "north-stairs",
                label: "North Stairwell",
                shortLabel: "N. Stairs",
                icon: "stairs",
                point: CGPoint(x: 0.45, y: 0.16),
                referenceNote: "North Core Stairwell by Restrooms"
            )
        ]
        
        if levelCode == "1F" || levelCode == "GF" {
            portals.insert(
                MTUFloorEntryPortal(
                    id: "main-entrance",
                    label: "Main Entrance Doors",
                    shortLabel: "Main Door",
                    icon: "door.left.hand.open",
                    point: CGPoint(x: 0.46, y: 0.89),
                    referenceNote: "South Main Plaza Entrance (\(building.southReference))"
                ),
                at: 0
            )
        }
        
        if building.hasSkywalkAccess && (levelCode == "1F" || levelCode == "2F") {
            portals.append(
                MTUFloorEntryPortal(
                    id: "skywalk-portal",
                    label: "Heated Skywalk / Tunnel",
                    shortLabel: "Skywalk",
                    icon: "snowflake",
                    point: CGPoint(x: 0.10, y: 0.50),
                    referenceNote: "Indoor Heated Connector (\(building.westReference))"
                )
            )
        }
        
        return portals
    }
    
    /// Architectural reference landmarks rendered on the floor plan
    func landmarks(for building: MTUBuilding) -> [MTUFloorLandmark] {
        var items: [MTUFloorLandmark] = [
            MTUFloorLandmark(id: "lm-elev", title: "Elevator", kind: .elevator, point: elevatorPoint),
            MTUFloorLandmark(id: "lm-stairs-s", title: "South Stairs", kind: .stairs, point: CGPoint(x: elevatorPoint.x, y: min(0.87, elevatorPoint.y + 0.08))),
            MTUFloorLandmark(id: "lm-stairs-n", title: "North Stairs", kind: .stairs, point: CGPoint(x: 0.45, y: 0.16)),
            MTUFloorLandmark(id: "lm-rest", title: "Restrooms", kind: .restroom, point: CGPoint(x: 0.45, y: 0.38)),
            MTUFloorLandmark(id: "lm-water", title: "Water / Refill", kind: .water, point: CGPoint(x: 0.45, y: 0.54))
        ]
        if levelCode == "1F" || levelCode == "GF" {
            items.append(MTUFloorLandmark(id: "lm-door", title: "Main Lobby Entrance", kind: .entrance, point: CGPoint(x: 0.46, y: 0.90)))
        }
        if building.hasSkywalkAccess && (levelCode == "1F" || levelCode == "2F") {
            items.append(MTUFloorLandmark(id: "lm-sky", title: "Skywalk Connector", kind: .skywalk, point: CGPoint(x: 0.11, y: 0.50)))
        }
        return items
    }
    
    /// Computes an orthogonal corridor-faithful path from the chosen portal to the target room
    func routeWaypoints(from portal: MTUFloorEntryPortal, to room: MTUFloorRoom) -> [CGPoint] {
        let start = portal.point
        let end = room.doorwayPoint
        let targetSpineX: CGFloat = (end.x <= 0.43) ? westHallwaySpineX : hallwaySpineX
        
        var pts: [CGPoint] = [start]
        
        // If starting from west skywalk portal
        if start.x < 0.20 {
            let entryCorridorPt = CGPoint(x: westHallwaySpineX, y: start.y)
            pts.append(entryCorridorPt)
            if abs(targetSpineX - westHallwaySpineX) > 0.04 {
                // Cross via North or South cross-hallway
                let crossY = (end.y < 0.50) ? northCrossHallY : southCrossHallY
                pts.append(CGPoint(x: westHallwaySpineX, y: crossY))
                pts.append(CGPoint(x: targetSpineX, y: crossY))
            }
            pts.append(CGPoint(x: targetSpineX, y: end.y))
            pts.append(end)
            return pts
        }
        
        // Standard routing from Central Elevator / Main Entrance / North Stairs
        let crossY: CGFloat
        if abs(start.y - northCrossHallY) < abs(start.y - southCrossHallY) {
            crossY = start.y
        } else {
            crossY = southCrossHallY
        }
        
        if abs(start.y - crossY) > 0.02 {
            pts.append(CGPoint(x: start.x, y: crossY))
        }
        pts.append(CGPoint(x: targetSpineX, y: crossY))
        pts.append(CGPoint(x: targetSpineX, y: end.y))
        pts.append(end)
        return pts
    }
    
    /// Calculates estimated walking distance in feet and turn-by-turn directions with relative landmarks
    func routeSummary(from portal: MTUFloorEntryPortal, to room: MTUFloorRoom, building: MTUBuilding) -> (distanceFeet: Int, seconds: Int, steps: [String]) {
        let pts = routeWaypoints(from: portal, to: room)
        var totalNormDist: CGFloat = 0
        for i in 1..<pts.count {
            let dx = pts[i].x - pts[i - 1].x
            let dy = pts[i].y - pts[i - 1].y
            totalNormDist += hypot(dx, dy)
        }
        let feet = max(35, Int((totalNormDist * 210.0).rounded()))
        let seconds = max(10, Int((Double(feet) / 4.2).rounded()))
        
        var steps: [String] = []
        if levelCode != "1F" && levelCode != "GF" && portal.id == "elevator" {
            steps.append("Take Central Elevator or Stairs up to \(levelCode) (\(levelTitle.components(separatedBy: "•").first?.trimmingCharacters(in: .whitespaces) ?? levelCode))")
        } else {
            steps.append("Start at \(portal.label) (\(portal.referenceNote))")
        }
        
        let corridorSide = (room.doorwayPoint.x <= 0.43) ? "West Corridor" : "East Main Corridor"
        let heading = (room.doorwayPoint.y < portal.point.y) ? "North" : "South"
        let passLandmark = (room.doorwayPoint.y < 0.42) ? "past Central Restrooms" : "along Main Hallway"
        steps.append("Walk \(heading) down \(corridorSide) (\(feet) ft) \(passLandmark)")
        
        let doorSide = (room.rect.midX > room.doorwayPoint.x) ? "on your Right (East Wall)" : "on your Left (West Wall)"
        steps.append("Arrive at \(room.roomNumber) (\(room.title)) \(doorSide)")
        
        return (feet, seconds, steps)
    }
}

// MARK: - Campus Building Model
struct MTUBuilding: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let buildingNumber: Int
    let category: MTULocationCategory
    let latitude: Double
    let longitude: Double
    let primaryHighlight: String
    let secondaryHighlight: String
    let openHoursText: String
    let isOpenNow: Bool
    let walkMinutesOutdoor: Int
    let walkMinutesIndoor: Int
    let hasSkywalkAccess: Bool
    let skywalkRouteSummary: String
    let phone: String
    let email: String
    let officialURL: String
    let matchingOfficePrefixes: [String]
    let floors: [MTUFloorLevel]
    
    // Spatial Orientation References (What is North, South, East, West of this building)
    var northReference: String {
        switch id {
        case "rekhi": return "U.S. 41 & Portage Lake Overlook"
        case "admin": return "U.S. 41 & Lakeshore Center (#100)"
        case "library": return "Husky Statue Plaza & U.S. 41"
        case "eerc": return "U.S. 41 & GLRC Overpass"
        case "mub": return "U.S. 41 & College Ave"
        case "glrc": return "Portage Lake Waterway & Dock"
        case "aob": return "College Ave & West Campus"
        case "wads": return "Townsend Drive & East Campus"
        case "mcallister": return "Townsend Drive & Lot 27"
        case "sdc": return "MacInnes Drive & Upper Campus"
        case "widmaier": return "Townsend Drive & Admin Building"
        case "lakeshore": return "Portage Lake Waterfront Dock"
        default: return "Portage Lake / North Campus"
        }
    }
    
    var southReference: String {
        switch id {
        case "rekhi": return "Townsend Drive & Fisher Hall (#20)"
        case "admin": return "Townsend Drive & Central Plaza"
        case "library": return "Townsend Drive & Dow Building (#8)"
        case "eerc": return "Townsend Drive & ME-EM Building (#112)"
        case "mub": return "Townsend Drive Shuttle Hub"
        case "glrc": return "U.S. 41 Pedestrian Overpass to Library"
        case "aob": return "Townsend Drive West Sidewalk"
        case "wads": return "McNair Residence Hall & Hillside"
        case "mcallister": return "MacInnes Drive & Widmaier House"
        case "sdc": return "Gates Tennis Center & Ski Trails"
        case "widmaier": return "MacInnes Drive & SDC Arena (#24)"
        case "lakeshore": return "U.S. 41 & West Houghton"
        default: return "Townsend Drive Main Corridor"
        }
    }
    
    var westReference: String {
        switch id {
        case "rekhi": return "Van Pelt Library (#17 • Tunnel)"
        case "admin": return "MUB (#34) & AOB (#5)"
        case "library": return "MUB (#34 • Skywalk Bridge)"
        case "eerc": return "Rekhi Hall (#28 • Indoor Connector)"
        case "mub": return "Administration Building (#1)"
        case "glrc": return "Lakeshore Center (#100)"
        case "aob": return "ROTC Building & West Entry"
        case "wads": return "Daniell Heights & Campus Core"
        case "mcallister": return "Administration Building (#1)"
        case "sdc": return "Lot 24 & MacInnes Drive"
        case "widmaier": return "McAllister Welcome Center (#107)"
        case "lakeshore": return "Houghton Waterfront Trail"
        default: return "West Campus Core"
        }
    }
    
    var eastReference: String {
        switch id {
        case "rekhi": return "EERC (#7 • Indoor Walkway)"
        case "admin": return "MUB (#34) & Husky Plaza"
        case "library": return "Rekhi Hall (#28 • Tunnel)"
        case "eerc": return "Chem Sci (#19) & Wadsworth (#37)"
        case "mub": return "Van Pelt Library (#17 • Skywalk)"
        case "glrc": return "U.S. Coast Guard Dock"
        case "aob": return "Administration Building (#1)"
        case "wads": return "East Campus Residence Loop"
        case "mcallister": return "Van Pelt Library South Lawn"
        case "sdc": return "Sherman Field & Ice Arena"
        case "widmaier": return "ROTC & Academic Core"
        case "lakeshore": return "GLRC (#102) Waterfront"
        default: return "East Campus Core"
        }
    }
    
    var relativeCampusDescription: String {
        "Bldg #\(buildingNumber) • West: \(westReference) • East: \(eastReference)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func == (lhs: MTUBuilding, rhs: MTUBuilding) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Campus Landmarks, Skywalks & Shuttle Models
struct MTUCampusLandmark: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let coordinate: CLLocationCoordinate2D
}

struct MTUSkywalkSegment: Identifiable {
    let id = UUID()
    let title: String
    let fromCoord: CLLocationCoordinate2D
    let toCoord: CLLocationCoordinate2D
}

struct MTUShuttleStop: Identifiable {
    let id = UUID()
    let name: String
    let routeName: String
    let etaMinutes: Int
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Verified Complete MTU Campus Dataset (All 12 Buildings & All 76 Contacts)
enum MTUCampusData {
    static let campusCenter = CLLocationCoordinate2D(latitude: 47.1189, longitude: -88.5472)
    
    static let campusLandmarks: [MTUCampusLandmark] = [
        MTUCampusLandmark(
            id: "husky-plaza",
            name: "The Husky Statue Plaza",
            subtitle: "Central Quad Anchor • Between Library & Rekhi",
            icon: "pawprint.fill",
            coordinate: CLLocationCoordinate2D(latitude: 47.1188, longitude: -88.5463)
        ),
        MTUCampusLandmark(
            id: "us41-overpass",
            name: "U.S. 41 Pedestrian Overpass",
            subtitle: "Bridge to GLRC Waterfront",
            icon: "figure.walk.Motion",
            coordinate: CLLocationCoordinate2D(latitude: 47.1197, longitude: -88.5458)
        ),
        MTUCampusLandmark(
            id: "portage-waterfront",
            name: "Portage Lake Waterway",
            subtitle: "North Shoreline Orientation Reference",
            icon: "water.waves",
            coordinate: CLLocationCoordinate2D(latitude: 47.1211, longitude: -88.5468)
        ),
        MTUCampusLandmark(
            id: "townsend-corridor",
            name: "Townsend Drive Circle",
            subtitle: "Main South Campus Road & Shuttle Loop",
            icon: "road.lanes",
            coordinate: CLLocationCoordinate2D(latitude: 47.1181, longitude: -88.5478)
        )
    ]
    
    static let skywalkSegments: [MTUSkywalkSegment] = [
        MTUSkywalkSegment(
            title: "MUB → Van Pelt Library Skywalk",
            fromCoord: CLLocationCoordinate2D(latitude: 47.1192, longitude: -88.5494),
            toCoord: CLLocationCoordinate2D(latitude: 47.1187, longitude: -88.5469)
        ),
        MTUSkywalkSegment(
            title: "Van Pelt Library → Rekhi Hall Tunnel/Connector",
            fromCoord: CLLocationCoordinate2D(latitude: 47.1187, longitude: -88.5469),
            toCoord: CLLocationCoordinate2D(latitude: 47.1189, longitude: -88.5458)
        ),
        MTUSkywalkSegment(
            title: "Rekhi Hall → EERC Indoor Walkway",
            fromCoord: CLLocationCoordinate2D(latitude: 47.1189, longitude: -88.5458),
            toCoord: CLLocationCoordinate2D(latitude: 47.1185, longitude: -88.5447)
        ),
        MTUSkywalkSegment(
            title: "Library North Exit → U.S. 41 Overpass → GLRC",
            fromCoord: CLLocationCoordinate2D(latitude: 47.1187, longitude: -88.5469),
            toCoord: CLLocationCoordinate2D(latitude: 47.1205, longitude: -88.5452)
        )
    ]
    
    static let shuttleStops: [MTUShuttleStop] = [
        MTUShuttleStop(
            name: "MUB Husky Shuttle Hub",
            routeName: "Campus Core Loop",
            etaMinutes: 2,
            coordinate: CLLocationCoordinate2D(latitude: 47.1195, longitude: -88.5490)
        ),
        MTUShuttleStop(
            name: "Rekhi / Library Stop",
            routeName: "East Campus Shuttle",
            etaMinutes: 5,
            coordinate: CLLocationCoordinate2D(latitude: 47.1183, longitude: -88.5462)
        ),
        MTUShuttleStop(
            name: "Wadsworth Hall Stop",
            routeName: "Residential Express",
            etaMinutes: 4,
            coordinate: CLLocationCoordinate2D(latitude: 47.1174, longitude: -88.5432)
        )
    ]
    
    /// Generates an outdoor/indoor multi-point campus route from the Husky Plaza / MUB Hub to any building
    static func campusRouteCoordinates(to building: MTUBuilding, winterMode: Bool) -> [CLLocationCoordinate2D] {
        let mubHub = CLLocationCoordinate2D(latitude: 47.1192, longitude: -88.5494)
        let libraryHub = CLLocationCoordinate2D(latitude: 47.1187, longitude: -88.5469)
        let rekhiHub = CLLocationCoordinate2D(latitude: 47.1189, longitude: -88.5458)
        let townsendMid = CLLocationCoordinate2D(latitude: 47.1183, longitude: -88.5478)
        
        switch building.id {
        case "mub":
            return [townsendMid, mubHub]
        case "library":
            return [mubHub, libraryHub]
        case "rekhi":
            return winterMode ? [mubHub, libraryHub, rekhiHub] : [mubHub, townsendMid, rekhiHub]
        case "eerc":
            return winterMode ? [mubHub, libraryHub, rekhiHub, building.coordinate] : [mubHub, townsendMid, rekhiHub, building.coordinate]
        case "glrc":
            let overpass = CLLocationCoordinate2D(latitude: 47.1197, longitude: -88.5458)
            return [mubHub, libraryHub, overpass, building.coordinate]
        default:
            return [mubHub, townsendMid, building.coordinate]
        }
    }
    
    static let buildings: [MTUBuilding] = [
        // =========================================================================
        // 1. Kanwal and Ann Rekhi Hall (Bldg #28) — All 29 CS & Computing Contacts
        // =========================================================================
        MTUBuilding(
            id: "rekhi",
            name: "Kanwal and Ann Rekhi Hall",
            shortName: "Rekhi Hall",
            buildingNumber: 28,
            category: .facultyOffices,
            latitude: 47.1189,
            longitude: -88.5458,
            primaryHighlight: "CS Main Office & Advising • Rm 322",
            secondaryHighlight: "CCLC Tutoring Center (Rm 209) & Lecture Hall 214",
            openHoursText: "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 4,
            walkMinutesIndoor: 3,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "MUB 2F Skywalk → Library 1F East Tunnel → Rekhi Hall West Portal (3 min heated walk)",
            phone: "906-487-2209",
            email: "cs@mtu.edu",
            officialURL: "https://www.mtu.edu/cs/",
            matchingOfficePrefixes: ["Rekhi"],
            floors: [
                // Rekhi 1st Floor (All 1F offices: 102, 103, 104, 107, 108, 110 + Labs)
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Computing Labs, IT Dir & Associate Dean",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        // East Wing (102, 103, 104, 107)
                        MTUFloorRoom(id: "rekhi-102", roomNumber: "Rm 102", title: "Stella Otoo", subtitle: "Computer Science • Rekhi Hall 102", roleBadge: "Teaching Prof", officeHours: "Mon/Wed 1:30–3:30 PM", phone: "906-487-3602", email: "sotoo@mtu.edu", rect: CGRect(x: 0.59, y: 0.12, width: 0.27, height: 0.16), doorwayPoint: CGPoint(x: 0.59, y: 0.20)),
                        MTUFloorRoom(id: "rekhi-103", roomNumber: "Rm 103", title: "Todd O. Arney", subtitle: "Applied Computing • Rekhi Hall 103", roleBadge: "IT Program Dir", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-1085", email: "toarney@mtu.edu", rect: CGRect(x: 0.59, y: 0.31, width: 0.27, height: 0.16), doorwayPoint: CGPoint(x: 0.59, y: 0.39)),
                        MTUFloorRoom(id: "rekhi-104", roomNumber: "Rm 104", title: "Serein Al-Ratrout", subtitle: "Computer Science • Rekhi Hall 104", roleBadge: "Assoc Teaching Prof", officeHours: "Tue/Thu 2:00–4:00 PM", phone: "906-487-2518", email: "salratro@mtu.edu", rect: CGRect(x: 0.59, y: 0.50, width: 0.27, height: 0.16), doorwayPoint: CGPoint(x: 0.59, y: 0.58)),
                        MTUFloorRoom(id: "rekhi-107", roomNumber: "Rm 107", title: "Dr. Ronghua (Sam) Xu", subtitle: "Applied Computing • Rekhi Hall 107", roleBadge: "Assistant Prof", officeHours: "Tue/Thu 10:00–12:00 PM", phone: "906-487-3386", email: "ronghuax@mtu.edu", rect: CGRect(x: 0.59, y: 0.69, width: 0.27, height: 0.16), doorwayPoint: CGPoint(x: 0.59, y: 0.77)),
                        // West Wing (108, 110, 112 Lab, 118 Lab)
                        MTUFloorRoom(id: "rekhi-108", roomNumber: "Rm 108", title: "Tim Van Wagner", subtitle: "Applied Computing • Rekhi Hall 108", roleBadge: "Assoc Teaching Prof", officeHours: "Mon/Wed 10:00–12:00 PM", phone: "906-487-2230", email: "tavanwag@mtu.edu", rect: CGRect(x: 0.08, y: 0.12, width: 0.25, height: 0.16), doorwayPoint: CGPoint(x: 0.33, y: 0.20)),
                        MTUFloorRoom(id: "rekhi-110", roomNumber: "Rm 110", title: "Dr. Yu Cai", subtitle: "College of Computing • Rekhi Hall 110", roleBadge: "Associate Dean", officeHours: "Open 8:30 AM – 4:30 PM", phone: "906-487-1471", email: "cai@mtu.edu", rect: CGRect(x: 0.08, y: 0.31, width: 0.25, height: 0.16), doorwayPoint: CGPoint(x: 0.33, y: 0.39)),
                        MTUFloorRoom(id: "rekhi-112", roomNumber: "Rm 112", title: "Systems & Linux Lab", subtitle: "Undergraduate Computing Lab • Rekhi 112", roleBadge: "Computer Lab", officeHours: "24/7 HuskyCard Access", phone: "906-487-2209", email: "cs@mtu.edu", rect: CGRect(x: 0.08, y: 0.56, width: 0.25, height: 0.24), doorwayPoint: CGPoint(x: 0.33, y: 0.68))
                    ]
                ),
                // Rekhi 2nd Floor (All 13 rooms: 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 214, 221)
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • CCLC Tutoring, Dean's Suite & CS Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        // East Wing (7 rooms: 202, 203, 204, 205, 206, 207, 208)
                        MTUFloorRoom(id: "rekhi-202", roomNumber: "Rm 202", title: "Dr. Anwar Walid", subtitle: "ICC Director & CS • Rekhi Hall 202", roleBadge: "ICC Exec Dir", officeHours: "By Appointment", phone: "906-487-2514", email: "aiwalid@mtu.edu", rect: CGRect(x: 0.59, y: 0.09, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.14)),
                        MTUFloorRoom(id: "rekhi-203", roomNumber: "Rm 203", title: "Dr. Jianhui Yue", subtitle: "Computer Science • Rekhi Hall 203", roleBadge: "Associate Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-1726", email: "jyue@mtu.edu", rect: CGRect(x: 0.59, y: 0.205, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.255)),
                        MTUFloorRoom(id: "rekhi-204", roomNumber: "Rm 204", title: "Dr. Robert Pastel", subtitle: "HCI & Usability • Rekhi Hall 204", roleBadge: "Associate Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-1639", email: "pastel@mtu.edu", rect: CGRect(x: 0.59, y: 0.32, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.37)),
                        MTUFloorRoom(id: "rekhi-205", roomNumber: "Rm 205", title: "Dr. Charles Wallace", subtitle: "Software Engineering • Rekhi Hall 205", roleBadge: "Professor", officeHours: "Tue/Thu 11:00–1:00 PM", phone: "906-487-3431", email: "wallace@mtu.edu", rect: CGRect(x: 0.59, y: 0.435, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.485)),
                        MTUFloorRoom(id: "rekhi-206", roomNumber: "Rm 206", title: "Dr. Ali Ebnenasir", subtitle: "Dependable Systems • Rekhi Hall 206", roleBadge: "Associate Prof", officeHours: "Mon/Wed 3:00–4:30 PM", phone: "906-487-4372", email: "aebnenas@mtu.edu", rect: CGRect(x: 0.59, y: 0.55, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.60)),
                        MTUFloorRoom(id: "rekhi-207", roomNumber: "Rm 207", title: "Dr. Jie Wu", subtitle: "Computer Science • Rekhi Hall 207", roleBadge: "Assistant Prof", officeHours: "Wed/Fri 1:00–3:00 PM", phone: "906-487-2320", email: "jie.jw.wu@mtu.edu", rect: CGRect(x: 0.59, y: 0.665, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.715)),
                        MTUFloorRoom(id: "rekhi-208", roomNumber: "Rm 208", title: "Dr. Keith Vertanen", subtitle: "Accessible Computing • Rekhi Hall 208", roleBadge: "Dave House Prof", officeHours: "Tue/Thu 2:00–3:30 PM", phone: "906-487-2331", email: "vertanen@mtu.edu", rect: CGRect(x: 0.59, y: 0.78, width: 0.27, height: 0.105), doorwayPoint: CGPoint(x: 0.59, y: 0.83)),
                        // West Wing (6 rooms: 209, 210, 211, 212, 214, 221)
                        MTUFloorRoom(id: "rekhi-209", roomNumber: "Rm 209", title: "CCLC & Dr. Leo Ureel II", subtitle: "CS Learning Center • Rekhi Hall 209", roleBadge: "Learning Center", officeHours: "Open Now • Walk-in Tutoring", phone: "906-487-1816", email: "ureel@mtu.edu", rect: CGRect(x: 0.08, y: 0.09, width: 0.25, height: 0.12), doorwayPoint: CGPoint(x: 0.33, y: 0.15)),
                        MTUFloorRoom(id: "rekhi-210", roomNumber: "Rm 210", title: "Dr. Scott A. Kuhl", subtitle: "Graphics & VR • Rekhi Hall 210", roleBadge: "Associate Prof", officeHours: "Mon/Wed 11:00–12:30 PM", phone: "906-487-2798", email: "kuhl@mtu.edu", rect: CGRect(x: 0.08, y: 0.22, width: 0.25, height: 0.11), doorwayPoint: CGPoint(x: 0.33, y: 0.275)),
                        MTUFloorRoom(id: "rekhi-211", roomNumber: "Rm 211", title: "Dr. Briana Bettin", subtitle: "CS Education & UX • Rekhi Hall 211", roleBadge: "Associate Prof", officeHours: "Open until 4:00 PM", phone: "906-487-1833", email: "bcbettin@mtu.edu", rect: CGRect(x: 0.08, y: 0.34, width: 0.25, height: 0.11), doorwayPoint: CGPoint(x: 0.33, y: 0.395)),
                        MTUFloorRoom(id: "rekhi-212", roomNumber: "Rm 212", title: "Dr. Michael Walker", subtitle: "Human-Robot Interaction • Rekhi Hall 212", roleBadge: "Assistant Prof", officeHours: "Tue/Thu 3:00–4:30 PM", phone: "906-487-3392", email: "miwalker@mtu.edu", rect: CGRect(x: 0.08, y: 0.54, width: 0.25, height: 0.11), doorwayPoint: CGPoint(x: 0.33, y: 0.595)),
                        MTUFloorRoom(id: "rekhi-214", roomNumber: "Rm 214", title: "Rekhi 214 Lecture Hall", subtitle: "Main Computing Auditorium • 2nd Floor", roleBadge: "Classroom", officeHours: "Next Class: 10:13 – 11:07", phone: "906-487-2209", email: "cs@mtu.edu", rect: CGRect(x: 0.08, y: 0.66, width: 0.25, height: 0.11), doorwayPoint: CGPoint(x: 0.33, y: 0.715)),
                        MTUFloorRoom(id: "rekhi-221", roomNumber: "Rm 221", title: "Dr. Dennis Livesay", subtitle: "College of Computing • Rekhi Hall 221", roleBadge: "Dean of Computing", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2316", email: "dlivesay@mtu.edu", rect: CGRect(x: 0.08, y: 0.78, width: 0.25, height: 0.11), doorwayPoint: CGPoint(x: 0.33, y: 0.835))
                    ]
                ),
                // Rekhi 3rd Floor (All 11 offices: 301, 302, 303, 304, 307, 308, 309, 310, 311, 322, 323)
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • CS & Applied Computing Chairs, Advising & Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        // East Wing (6 rooms: 322, 323, 301, 302, 303, 304)
                        MTUFloorRoom(id: "rekhi-322", roomNumber: "Rm 322", title: "CS Main Office (Wang, Landsberg, Chittick)", subtitle: "Dr. Zhenlin Wang (Chair), Denise Landsberg (Advisor), Janna Chittick", roleBadge: "CS Dept & Advising", officeHours: "Open Now • 8:00 AM – 4:30 PM", phone: "906-487-3643", email: "dllandsb@mtu.edu", rect: CGRect(x: 0.59, y: 0.09, width: 0.27, height: 0.13), doorwayPoint: CGPoint(x: 0.59, y: 0.155)),
                        MTUFloorRoom(id: "rekhi-323", roomNumber: "Rm 323", title: "Dr. Daniel R. Fuhrmann", subtitle: "Applied Computing Chair • Rekhi Hall 323", roleBadge: "AC Dept Chair", officeHours: "Open 8:30 AM – 4:30 PM", phone: "906-487-2871", email: "fuhrmann@mtu.edu", rect: CGRect(x: 0.59, y: 0.23, width: 0.27, height: 0.12), doorwayPoint: CGPoint(x: 0.59, y: 0.29)),
                        MTUFloorRoom(id: "rekhi-301", roomNumber: "Rm 301", title: "Dr. Bo Chen", subtitle: "Cybersecurity Director • Rekhi Hall 301", roleBadge: "Associate Prof", officeHours: "Wed/Fri 10:00–12:00 PM", phone: "906-487-3149", email: "bchen@mtu.edu", rect: CGRect(x: 0.59, y: 0.36, width: 0.27, height: 0.12), doorwayPoint: CGPoint(x: 0.59, y: 0.42)),
                        MTUFloorRoom(id: "rekhi-302", roomNumber: "Rm 302", title: "Dr. Ruihong Zhang", subtitle: "Computer Science • Rekhi Hall 302", roleBadge: "Teaching Prof", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-1638", email: "ruihong@mtu.edu", rect: CGRect(x: 0.59, y: 0.49, width: 0.27, height: 0.12), doorwayPoint: CGPoint(x: 0.59, y: 0.55)),
                        MTUFloorRoom(id: "rekhi-303", roomNumber: "Rm 303", title: "Dr. Soner Onder", subtitle: "Computer Architecture • Rekhi Hall 303", roleBadge: "Professor", officeHours: "Tue/Thu 2:00–4:00 PM", phone: "906-487-2123", email: "soner@mtu.edu", rect: CGRect(x: 0.59, y: 0.62, width: 0.27, height: 0.12), doorwayPoint: CGPoint(x: 0.59, y: 0.68)),
                        MTUFloorRoom(id: "rekhi-304", roomNumber: "Rm 304", title: "Dr. Jean Mayo", subtitle: "CS Grad Program Director • Rekhi Hall 304", roleBadge: "Grad Director", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-3157", email: "jmayo@mtu.edu", rect: CGRect(x: 0.59, y: 0.75, width: 0.27, height: 0.13), doorwayPoint: CGPoint(x: 0.59, y: 0.815)),
                        // West Wing (5 rooms: 307, 308, 309, 310, 311)
                        MTUFloorRoom(id: "rekhi-307", roomNumber: "Rm 307", title: "Dr. Bo Zhang", subtitle: "Machine Learning & AI • Rekhi Hall 307", roleBadge: "Assistant Prof", officeHours: "Tue/Thu 1:30–3:30 PM", phone: "906-487-2364", email: "bo.zhang@mtu.edu", rect: CGRect(x: 0.08, y: 0.10, width: 0.25, height: 0.14), doorwayPoint: CGPoint(x: 0.33, y: 0.17)),
                        MTUFloorRoom(id: "rekhi-308", roomNumber: "Rm 308", title: "Dr. Gorkem Asilioglu", subtitle: "Computer Science • Rekhi Hall 308", roleBadge: "Assoc Teaching Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-1643", email: "galolu@mtu.edu", rect: CGRect(x: 0.08, y: 0.26, width: 0.25, height: 0.14), doorwayPoint: CGPoint(x: 0.33, y: 0.33)),
                        MTUFloorRoom(id: "rekhi-309", roomNumber: "Rm 309", title: "Dr. Nilufer Onder", subtitle: "Undergrad Program Dir • Rekhi Hall 309", roleBadge: "Undergrad Dir", officeHours: "Open until 3:30 PM", phone: "906-487-1641", email: "nilufer@mtu.edu", rect: CGRect(x: 0.08, y: 0.42, width: 0.25, height: 0.14), doorwayPoint: CGPoint(x: 0.33, y: 0.49)),
                        MTUFloorRoom(id: "rekhi-310", roomNumber: "Rm 310", title: "Dr. Koloud Al Khamaiseh", subtitle: "Computer Science • Rekhi Hall 310", roleBadge: "Teaching Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-3619", email: "kalkhama@mtu.edu", rect: CGRect(x: 0.08, y: 0.58, width: 0.25, height: 0.14), doorwayPoint: CGPoint(x: 0.33, y: 0.65)),
                        MTUFloorRoom(id: "rekhi-311", roomNumber: "Rm 311", title: "Dr. Yakov Nekrich", subtitle: "Algorithms & Data Structures • Rekhi Hall 311", roleBadge: "Associate Prof", officeHours: "Mon/Wed 11:00–1:00 PM", phone: "906-487-2271", email: "yakov@mtu.edu", rect: CGRect(x: 0.08, y: 0.74, width: 0.25, height: 0.14), doorwayPoint: CGPoint(x: 0.33, y: 0.81))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 2. Administration Building (Bldg #1) — All 10 Student Support Contacts
        // =========================================================================
        MTUBuilding(
            id: "admin",
            name: "Administration Building",
            shortName: "Admin Building",
            buildingNumber: 1,
            category: .studentSupport,
            latitude: 47.1195,
            longitude: -88.5482,
            primaryHighlight: "Waino Wahtera Center, Registrar & Dean • Rm 130",
            secondaryHighlight: "Financial Aid (103) • Career Services (220) • Grad School (414)",
            openHoursText: "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 3,
            walkMinutesIndoor: 3,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Exit MUB West Doors → 1 min cleared plaza walk across to Admin South Entrance",
            phone: "906-487-3558",
            email: "success@mtu.edu",
            officialURL: "https://www.mtu.edu/success/",
            matchingOfficePrefixes: ["Administration Building"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Student Success, Registrar, Financial Aid & Parking",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "admin-130", roomNumber: "Rm 130", title: "Waino Wahtera Center for Student Success", subtitle: "Academic Support, Coaching & Orientation • Admin 130", roleBadge: "Academic Support", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-3558", email: "success@mtu.edu", rect: CGRect(x: 0.59, y: 0.10, width: 0.27, height: 0.18), doorwayPoint: CGPoint(x: 0.59, y: 0.19)),
                        MTUFloorRoom(id: "admin-130-reg", roomNumber: "Rm 130A", title: "Registrar's Office", subtitle: "Student Affairs & Enrollment • Administration Building 130", roleBadge: "Registrar", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2319", email: "registrar@mtu.edu", rect: CGRect(x: 0.59, y: 0.30, width: 0.27, height: 0.18), doorwayPoint: CGPoint(x: 0.59, y: 0.39)),
                        MTUFloorRoom(id: "admin-130-dean", roomNumber: "Rm 130B", title: "Dean of Students Office", subtitle: "Student Affairs & Advocacy • Administration Building 130", roleBadge: "Dean of Students", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2212", email: "deanofstudents@mtu.edu", rect: CGRect(x: 0.59, y: 0.50, width: 0.27, height: 0.18), doorwayPoint: CGPoint(x: 0.59, y: 0.59)),
                        MTUFloorRoom(id: "admin-130-sds", roomNumber: "Rm 130C", title: "Student Disability Services", subtitle: "Accommodations & Testing • Administration Building 130", roleBadge: "Accessibility", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2345", email: "sds@mtu.edu", rect: CGRect(x: 0.59, y: 0.70, width: 0.27, height: 0.18), doorwayPoint: CGPoint(x: 0.59, y: 0.79)),
                        MTUFloorRoom(id: "admin-103", roomNumber: "Rm 103", title: "Student Financial Services & Financial Aid", subtitle: "Billing, Scholarships & Loans • Admin 103", roleBadge: "Financial Aid", officeHours: "Open Now • 8:00 AM – 4:30 PM", phone: "906-487-2622", email: "finaid@mtu.edu", rect: CGRect(x: 0.08, y: 0.14, width: 0.25, height: 0.26), doorwayPoint: CGPoint(x: 0.33, y: 0.27)),
                        MTUFloorRoom(id: "admin-100", roomNumber: "Rm 100", title: "Transportation & Parking Services", subtitle: "Permits, Lot Assignments & Shuttle • Admin 100", roleBadge: "Parking & Transit", officeHours: "Open 8:00 AM – 4:30 PM", phone: "906-487-1441", email: "parking@mtu.edu", rect: CGRect(x: 0.08, y: 0.46, width: 0.25, height: 0.26), doorwayPoint: CGPoint(x: 0.33, y: 0.59))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Career Services & International Programs",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "admin-220", roomNumber: "Rm 220", title: "Career Services", subtitle: "Career Fair Prep, Co-ops & Resume Reviews • Admin 220", roleBadge: "Career Advising", officeHours: "Open Now • Drop-in Hours", phone: "906-487-2313", email: "career@mtu.edu", rect: CGRect(x: 0.59, y: 0.14, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.30)),
                        MTUFloorRoom(id: "admin-200", roomNumber: "Rm 200", title: "International Programs and Services", subtitle: "Global Campus, Visas & Study Abroad • Admin 200", roleBadge: "International", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2160", email: "ips@mtu.edu", rect: CGRect(x: 0.59, y: 0.52, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.67)),
                        MTUFloorRoom(id: "admin-210", roomNumber: "Rm 210", title: "Employer Interview Suites", subtitle: "On-Campus Recruiting Rooms • Admin 210", roleBadge: "Interview Rooms", officeHours: "8:00 AM – 5:00 PM", phone: "906-487-2313", email: "career@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.32), doorwayPoint: CGPoint(x: 0.33, y: 0.34))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • Center for Student Mental Health & Well-being",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "admin-301", roomNumber: "Rm 301", title: "Center for Student Mental Health and Well-being", subtitle: "Counseling & Wellness Services • Admin 301", roleBadge: "Counseling", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2538", email: "counseling@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.36), doorwayPoint: CGPoint(x: 0.59, y: 0.34)),
                        MTUFloorRoom(id: "admin-310", roomNumber: "Rm 310", title: "Mindfulness & Group Wellness Suite", subtitle: "Peer Wellness Workshops • Admin 310", roleBadge: "Wellness Lab", officeHours: "Open 9:00 AM – 4:30 PM", phone: "906-487-2538", email: "counseling@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.32), doorwayPoint: CGPoint(x: 0.33, y: 0.34))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "4F",
                    levelTitle: "4th Floor • Graduate School & Academic Leadership",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "admin-414", roomNumber: "Rm 414", title: "Graduate School Office", subtitle: "Graduate Programs, Theses & Fellowships • Admin 414", roleBadge: "Grad School", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2327", email: "gradschool@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.36), doorwayPoint: CGPoint(x: 0.59, y: 0.34)),
                        MTUFloorRoom(id: "admin-405", roomNumber: "Rm 405", title: "Provost & Academic Affairs Suite", subtitle: "University Academic Administration • Admin 405", roleBadge: "Administration", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2440", email: "provost@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.32), doorwayPoint: CGPoint(x: 0.33, y: 0.34))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 3. Van Pelt and Opie Library (Bldg #17)
        // =========================================================================
        MTUBuilding(
            id: "library",
            name: "Van Pelt and Opie Library",
            shortName: "Van Pelt & Opie Library",
            buildingNumber: 17,
            category: .learningCenters,
            latitude: 47.1187,
            longitude: -88.5469,
            primaryHighlight: "IT Service Center & HuskyCard • Rm 101",
            secondaryHighlight: "Library Service Center & 24/7 Commons • 1st Floor",
            openHoursText: "Open 24 Hours • IT Desk until 6:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 3,
            walkMinutesIndoor: 2,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Direct Skywalk from MUB 2F → Library Concourse → East Tunnel to Rekhi Hall",
            phone: "906-487-2508",
            email: "library@mtu.edu",
            officialURL: "https://www.mtu.edu/library/",
            matchingOfficePrefixes: ["Van Pelt", "Library"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • IT Helpdesk, Service Center & Writing Center",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "lib-101", roomNumber: "Rm 101", title: "Information Technology (IT) Service Center", subtitle: "Tech Support, Wi-Fi & HuskyCard ID • Library 101", roleBadge: "IT & HuskyCard", officeHours: "Open Now • 8:00 AM – 6:00 PM", phone: "906-487-1111", email: "it-help@mtu.edu", rect: CGRect(x: 0.59, y: 0.14, width: 0.27, height: 0.28), doorwayPoint: CGPoint(x: 0.59, y: 0.28)),
                        MTUFloorRoom(id: "lib-svc", roomNumber: "1st Fl", title: "Van Pelt and Opie Library Service Center", subtitle: "Library Service Center, 1st Floor • Reserves & Printing", roleBadge: "Library Services", officeHours: "Open 24 Hours", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.59, y: 0.48, width: 0.27, height: 0.28), doorwayPoint: CGPoint(x: 0.59, y: 0.62)),
                        MTUFloorRoom(id: "lib-118", roomNumber: "Rm 118", title: "MTU Writing Center", subtitle: "Peer Writing & Communication Tutoring • 1st Floor West", roleBadge: "Learning Center", officeHours: "Open 10:00 AM – 8:00 PM", phone: "906-487-3251", email: "writing@mtu.edu", rect: CGRect(x: 0.08, y: 0.16, width: 0.25, height: 0.26), doorwayPoint: CGPoint(x: 0.33, y: 0.29))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Collaborative Study Pods & MUB Skywalk Bridge",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "lib-201", roomNumber: "Rm 201", title: "Group Study Suites (East Wing)", subtitle: "Reservable Collaboration Pods • Overlooking Husky Plaza", roleBadge: "Study Space", officeHours: "Reservable 24/7", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.31)),
                        MTUFloorRoom(id: "lib-220", roomNumber: "Rm 220", title: "West Skywalk Concourse to MUB", subtitle: "Heated Bridge to Memorial Union Building 2F", roleBadge: "Winter Route", officeHours: "Open 24 Hours", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.28), doorwayPoint: CGPoint(x: 0.33, y: 0.32))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • Quiet Study Zone & Historical Archives",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "lib-301", roomNumber: "Rm 301", title: "Silent Reading Room", subtitle: "Portage Lake Overlook Quiet Study Zone", roleBadge: "Quiet Study", officeHours: "Open 24 Hours", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.31)),
                        MTUFloorRoom(id: "lib-320", roomNumber: "Rm 320", title: "Copper Country Historical Archives", subtitle: "Special Collections & Reading Room • 3rd Floor West", roleBadge: "Archives", officeHours: "Mon–Fri 10:00 AM – 5:00 PM", phone: "906-487-2505", email: "copper@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.28), doorwayPoint: CGPoint(x: 0.33, y: 0.32))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 4. Electrical Energy Resources Center (EERC • Bldg #7) — All 15 Contacts across 1F, 2F, 4F, 5F, 6F, 7F
        // =========================================================================
        MTUBuilding(
            id: "eerc",
            name: "Electrical Energy Resources Center",
            shortName: "EERC",
            buildingNumber: 7,
            category: .facultyOffices,
            latitude: 47.1185,
            longitude: -88.5447,
            primaryHighlight: "ECE Dept Chair (Rm 121) & Advising (Rm 520)",
            secondaryHighlight: "The Alley Makerspace (Rm 518) & Applied Computing (4F)",
            openHoursText: "Open Now • 7:00 AM – 10:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 5,
            walkMinutesIndoor: 4,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "MUB Skywalk → Library → Rekhi Hall → EERC West Indoor Walkway (4 min heated walk)",
            phone: "906-487-2550",
            email: "ece@mtu.edu",
            officialURL: "https://www.mtu.edu/ece/",
            matchingOfficePrefixes: ["EERC"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • ECE Department Main Office & Energy Labs",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-121", roomNumber: "Rm 121", title: "Dr. Wayne W. Weaver", subtitle: "Electrical & Computer Engineering • EERC 121", roleBadge: "ECE Dept Chair", officeHours: "Open until 4:30 PM", phone: "906-487-1461", email: "wwweaver@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32)),
                        MTUFloorRoom(id: "eerc-101", roomNumber: "Rm 101", title: "Power & Energy Systems Lab", subtitle: "High-Bay Microgrid Research Lab • EERC 101", roleBadge: "Research Lab", officeHours: "8:00 AM – 6:00 PM", phone: "906-487-2550", email: "ece@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • ECE Grad Studies, Optics & Computing Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-220", roomNumber: "Rm 220", title: "Dr. Yunlong Xing", subtitle: "Applied Computing & CS • EERC 220", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 1:30–3:30 PM", phone: "906-487-2638", email: "yuxing@mtu.edu", rect: CGRect(x: 0.59, y: 0.14, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.25)),
                        MTUFloorRoom(id: "eerc-234", roomNumber: "Rm 234", title: "Dr. Aurenice M. Oliveira", subtitle: "ECE Grad Studies Director • EERC 234", roleBadge: "Associate Chair", officeHours: "Tue/Thu 1:30–3:30 PM", phone: "906-487-2494", email: "oliveira@mtu.edu", rect: CGRect(x: 0.59, y: 0.40, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.51)),
                        MTUFloorRoom(id: "eerc-236", roomNumber: "Rm 236", title: "Dr. Jeremy P. Bos", subtitle: "Autonomous Robotics & Optics • EERC 236", roleBadge: "Associate Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-3161", email: "jpbos@mtu.edu", rect: CGRect(x: 0.59, y: 0.66, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.77))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "4F",
                    levelTitle: "4th Floor • Applied Computing & Mechatronics Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-411", roomNumber: "Rm 411", title: "Dr. Nathir A. Rawashdeh", subtitle: "Applied Computing • EERC 411", roleBadge: "Assistant Prof", officeHours: "Tue/Thu 11:00–1:00 PM", phone: "906-487-1611", email: "narawash@mtu.edu", rect: CGRect(x: 0.59, y: 0.14, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.25)),
                        MTUFloorRoom(id: "eerc-412", roomNumber: "Rm 412", title: "Dr. Ashraf I. Saleem", subtitle: "Mechatronics Co-Director • EERC 412", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 10:00–12:00 PM", phone: "906-487-2384", email: "ashraf@mtu.edu", rect: CGRect(x: 0.59, y: 0.40, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.51)),
                        MTUFloorRoom(id: "eerc-413", roomNumber: "Rm 413", title: "Dr. Aleksandr Sergeyev", subtitle: "Applied Computing Grad Dir • EERC 413", roleBadge: "Grad Program Dir", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-2258", email: "avsergue@mtu.edu", rect: CGRect(x: 0.59, y: 0.66, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.77)),
                        MTUFloorRoom(id: "eerc-417", roomNumber: "Rm 417", title: "Dr. Nader Abu-Alrub", subtitle: "Applied Computing • EERC 417", roleBadge: "Teaching Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-4305", email: "nabualru@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.26), doorwayPoint: CGPoint(x: 0.33, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "5F",
                    levelTitle: "5th Floor • The Alley Makerspace & ECE Undergrad Advising",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-518", roomNumber: "Rm 518", title: "Dr. Shane Oberloier", subtitle: "The Alley Makerspace Director • EERC 518", roleBadge: "Makerspace Dir", officeHours: "Open Now • Prototyping Lab", phone: "906-487-2941", email: "swoberlo@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.31)),
                        MTUFloorRoom(id: "eerc-520", roomNumber: "Rm 520", title: "Christopher (Kit) Cischke", subtitle: "ECE Undergraduate Advising • EERC 520", roleBadge: "Associate Chair", officeHours: "Open until 4:00 PM", phone: "906-487-2011", email: "cmcischk@mtu.edu", rect: CGRect(x: 0.59, y: 0.50, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.65))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "6F",
                    levelTitle: "6th Floor • Microelectronics & Power Grid Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-612", roomNumber: "Rm 612", title: "Dr. Chee-Wooi Ten", subtitle: "Power Grid Cybersecurity • EERC 612", roleBadge: "Professor", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-0397", email: "ten@mtu.edu", rect: CGRect(x: 0.59, y: 0.14, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.25)),
                        MTUFloorRoom(id: "eerc-629", roomNumber: "Rm 629", title: "Glen E. Archer", subtitle: "Electrical & Computer Engineering • EERC 629", roleBadge: "Teaching Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-2789", email: "gearcher@mtu.edu", rect: CGRect(x: 0.59, y: 0.40, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.51)),
                        MTUFloorRoom(id: "eerc-630", roomNumber: "Rm 630", title: "Dr. Paul L. Bergstrom", subtitle: "Microfabrication & MEMS • EERC 630", roleBadge: "Professor", officeHours: "Tue/Thu 10:00–12:00 PM", phone: "906-487-2058", email: "paulb@mtu.edu", rect: CGRect(x: 0.59, y: 0.66, width: 0.27, height: 0.22), doorwayPoint: CGPoint(x: 0.59, y: 0.77))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "7F",
                    levelTitle: "7th Floor • Senior Design & Neuromorphic Computing",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "eerc-710", roomNumber: "Rm 710", title: "Dr. Hongyu An", subtitle: "Neuromorphic & VLSI Systems • EERC 710", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-3382", email: "hongyua@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.31)),
                        MTUFloorRoom(id: "eerc-731", roomNumber: "Rm 731", title: "Dr. Anthony (Tony) Pinar", subtitle: "Senior Design Coordinator • EERC 731", roleBadge: "Senior Design Dir", officeHours: "Open until 4:00 PM", phone: "906-487-0024", email: "ajpinar@mtu.edu", rect: CGRect(x: 0.59, y: 0.50, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.65))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 5. Memorial Union Building (MUB • Bldg #34)
        // =========================================================================
        MTUBuilding(
            id: "mub",
            name: "Memorial Union Building (MUB)",
            shortName: "MUB",
            buildingNumber: 34,
            category: .transitDining,
            latitude: 47.1192,
            longitude: -88.5494,
            primaryHighlight: "Student Leadership & Involvement • Rm 112",
            secondaryHighlight: "Husky Den Food Court (2F) & Skywalk Hub",
            openHoursText: "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 2,
            walkMinutesIndoor: 1,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Central Skywalk Hub connecting directly to Van Pelt Library 2F & East Campus",
            phone: "906-487-1963",
            email: "activities@mtu.edu",
            officialURL: "https://www.mtu.edu/union/",
            matchingOfficePrefixes: ["Memorial Union"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Student Leadership, Bookstore & Bowling",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "mub-112", roomNumber: "Rm 112", title: "Student Leadership and Involvement", subtitle: "Student Orgs, Greek Life & Events • MUB 112", roleBadge: "Student Orgs", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32)),
                        MTUFloorRoom(id: "mub-101", roomNumber: "Rm 101", title: "MTU Campus Bookstore", subtitle: "Textbooks, Tech Gear & Husky Apparel • MUB 101", roleBadge: "Campus Store", officeHours: "Open 8:30 AM – 5:00 PM", phone: "906-487-2410", email: "bookstore@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Husky Den Food Court & Library Skywalk",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "mub-sky", roomNumber: "Skywalk", title: "MUB → Library Heated Skywalk Entrance", subtitle: "Indoor Bridge over Townsend Drive to Library 2F", roleBadge: "Winter Route", officeHours: "Open 24 Hours", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.31)),
                        MTUFloorRoom(id: "mub-201", roomNumber: "Rm 201", title: "Husky Den Food Court & Commons", subtitle: "Main Campus Dining & Lounge • MUB 2F", roleBadge: "Dining Hub", officeHours: "Open 7:30 AM – 9:00 PM", phone: "906-487-1963", email: "dining@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • MUB Ballroom & Conference Suites",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "mub-ballroom", roomNumber: "Rm 300", title: "MUB Ballroom", subtitle: "Career Fair, Employer Booths & Campus Banquets", roleBadge: "Event Space", officeHours: "Event Hours", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.34), doorwayPoint: CGPoint(x: 0.59, y: 0.33))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 6. Great Lakes Research Center (GLRC • Bldg #102)
        // =========================================================================
        MTUBuilding(
            id: "glrc",
            name: "Great Lakes Research Center",
            shortName: "GLRC",
            buildingNumber: 102,
            category: .learningCenters,
            latitude: 47.1205,
            longitude: -88.5452,
            primaryHighlight: "GLRC Director (Dr. Timothy Havens) • Rm 307",
            secondaryHighlight: "Data Science & Sensing (Dr. Evan Lucas) • Rm 211",
            openHoursText: "Open Now • 8:00 AM – 6:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 6,
            walkMinutesIndoor: 5,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Exit Library North Door → Cross U.S. 41 Pedestrian Overpass to Portage Lake Waterfront",
            phone: "906-487-3115",
            email: "thavens@mtu.edu",
            officialURL: "https://www.mtu.edu/greatlakes/",
            matchingOfficePrefixes: ["GLRC"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Marine Autonomous Vessels & Waterfront Dock",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "glrc-101", roomNumber: "Rm 101", title: "Boathouse & Waterfront Lab", subtitle: "Portage Lake Research Dock • GLRC 1F", roleBadge: "Research Lab", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-3115", email: "thavens@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Data Science & Environmental Sensing",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "glrc-211", roomNumber: "Rm 211", title: "Dr. Evan Lucas", subtitle: "Data Science & Computer Science • GLRC 211", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-2094", email: "eglucas@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • GLRC Executive Suite & AI Labs",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "glrc-307", roomNumber: "Rm 307", title: "Dr. Timothy C. Havens", subtitle: "GLRC Executive Director & CS Prof • GLRC 307", roleBadge: "GLRC Director", officeHours: "Open until 4:30 PM", phone: "906-487-3115", email: "thavens@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 7. Academic Office Building (AOB • Bldg #5) — All 10 College of Business Contacts
        // =========================================================================
        MTUBuilding(
            id: "aob",
            name: "Academic Office Building (College of Business)",
            shortName: "AOB • Business",
            buildingNumber: 5,
            category: .facultyOffices,
            latitude: 47.1198,
            longitude: -88.5508,
            primaryHighlight: "Business Advising (Ryan Neely) • Rm 108",
            secondaryHighlight: "Dean's Suite (Rm 103) & MIS / Finance Faculty (GF & 1F)",
            openHoursText: "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 4,
            walkMinutesIndoor: 4,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Walk west from Admin Building along Townsend Drive sidewalk (4 min)",
            phone: "906-487-2668",
            email: "business@mtu.edu",
            officialURL: "https://www.mtu.edu/business/",
            matchingOfficePrefixes: ["Academic Office Building"],
            floors: [
                // AOB Ground Floor (G002, G010 + Trading Lab)
                MTUFloorLevel(
                    levelCode: "GF",
                    levelTitle: "Ground Floor • Assistant Dean, MIS Analytics & Trading Lab",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "aob-g002", roomNumber: "Rm G002", title: "Dr. Jonathan Leinonen", subtitle: "Assistant Dean & Teaching Prof • AOB G002", roleBadge: "Assistant Dean", officeHours: "Open 8:30 AM – 4:30 PM", phone: "906-487-2598", email: "jeleinon@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.28), doorwayPoint: CGPoint(x: 0.59, y: 0.30)),
                        MTUFloorRoom(id: "aob-g010", roomNumber: "Rm G010", title: "Dr. Jeffrey Wall", subtitle: "MIS & Business Analytics • AOB G010", roleBadge: "Associate Prof", officeHours: "Mon/Wed 1:30–3:30 PM", phone: "906-487-1707", email: "jdwall@mtu.edu", rect: CGRect(x: 0.59, y: 0.48, width: 0.27, height: 0.28), doorwayPoint: CGPoint(x: 0.59, y: 0.62)),
                        MTUFloorRoom(id: "aob-g014", roomNumber: "Rm G014", title: "APMP Financial Trading Lab", subtitle: "Bloomberg Terminals & Portfolio Lab • AOB GF", roleBadge: "Finance Lab", officeHours: "Open 8:00 AM – 9:00 PM", phone: "906-487-2668", email: "business@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                ),
                // AOB 1st Floor (All 8 offices: 103, 105, 108, 109, 114, 115, 121, 123)
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Business Dean's Suite, Advising & Faculty",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        // East Wing (103, 105, 108, 109)
                        MTUFloorRoom(id: "aob-103", roomNumber: "Rm 103", title: "Dr. Sri Beldona", subtitle: "Dean of College of Business • AOB 103", roleBadge: "Business Dean", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2668", email: "sbeldona@mtu.edu", rect: CGRect(x: 0.59, y: 0.10, width: 0.27, height: 0.17), doorwayPoint: CGPoint(x: 0.59, y: 0.185)),
                        MTUFloorRoom(id: "aob-105", roomNumber: "Rm 105", title: "Dr. Manish K. Srivastava", subtitle: "Associate Dean & Professor • AOB 105", roleBadge: "Associate Dean", officeHours: "Open 8:30 AM – 4:30 PM", phone: "906-487-1991", email: "mksrivas@mtu.edu", rect: CGRect(x: 0.59, y: 0.29, width: 0.27, height: 0.17), doorwayPoint: CGPoint(x: 0.59, y: 0.375)),
                        MTUFloorRoom(id: "aob-108", roomNumber: "Rm 108", title: "Ryan Neely", subtitle: "Undergraduate Academic Advisor • AOB 108", roleBadge: "Academic Advisor", officeHours: "Open Now • Drop-in until 4:00 PM", phone: "906-487-3597", email: "rmneely@mtu.edu", rect: CGRect(x: 0.59, y: 0.48, width: 0.27, height: 0.17), doorwayPoint: CGPoint(x: 0.59, y: 0.565)),
                        MTUFloorRoom(id: "aob-109", roomNumber: "Rm 109", title: "Marie Cleveland", subtitle: "Student Success & Outreach • AOB 109", roleBadge: "Student Success", officeHours: "Open 8:00 AM – 4:30 PM", phone: "906-487-3055", email: "mlclevel@mtu.edu", rect: CGRect(x: 0.59, y: 0.67, width: 0.27, height: 0.17), doorwayPoint: CGPoint(x: 0.59, y: 0.755)),
                        // West Wing (114, 115, 121, 123)
                        MTUFloorRoom(id: "aob-114", roomNumber: "Rm 114", title: "Laura J. Sieders", subtitle: "Accounting • Academic Office Building 114", roleBadge: "Teaching Prof", officeHours: "Tue/Thu 10:00–12:00 PM", phone: "906-487-3259", email: "ljsieder@mtu.edu", rect: CGRect(x: 0.08, y: 0.10, width: 0.25, height: 0.17), doorwayPoint: CGPoint(x: 0.33, y: 0.185)),
                        MTUFloorRoom(id: "aob-115", roomNumber: "Rm 115", title: "Dr. Dean Johnson", subtitle: "Finance & APMP Director • AOB 115", roleBadge: "Finance Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-1450", email: "dean@mtu.edu", rect: CGRect(x: 0.08, y: 0.29, width: 0.25, height: 0.17), doorwayPoint: CGPoint(x: 0.33, y: 0.375)),
                        MTUFloorRoom(id: "aob-121", roomNumber: "Rm 121", title: "Dr. Elham Asgari", subtitle: "Management & Entrepreneurship • AOB 121", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-2803", email: "easgari@mtu.edu", rect: CGRect(x: 0.08, y: 0.48, width: 0.25, height: 0.17), doorwayPoint: CGPoint(x: 0.33, y: 0.565)),
                        MTUFloorRoom(id: "aob-123", roomNumber: "Rm 123", title: "Dr. Jenny Apriesnig", subtitle: "Economics • Academic Office Building 123", roleBadge: "Associate Prof", officeHours: "Mon/Wed 10:00–12:00 PM", phone: "906-487-2223", email: "jlapries@mtu.edu", rect: CGRect(x: 0.08, y: 0.67, width: 0.25, height: 0.17), doorwayPoint: CGPoint(x: 0.33, y: 0.755))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 8. Wadsworth Hall (Bldg #37) — Residence Education & Housing Services (Rm 153)
        // =========================================================================
        MTUBuilding(
            id: "wads",
            name: "Wadsworth Hall",
            shortName: "Wadsworth Hall",
            buildingNumber: 37,
            category: .transitDining,
            latitude: 47.1173,
            longitude: -88.5430,
            primaryHighlight: "Residence Education & Housing Services • Rm 153",
            secondaryHighlight: "Wadsworth Dining Hall & Campus Care Clinic",
            openHoursText: "Open Now • Front Desk 7:00 AM – 11:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 6,
            walkMinutesIndoor: 5,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Take East Campus Shuttle or walk east past EERC along Townsend Drive (5 min)",
            phone: "906-487-2682",
            email: "housing@mtu.edu",
            officialURL: "https://www.mtu.edu/housing/",
            matchingOfficePrefixes: ["Wadsworth"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Housing Services Office, Dining & Clinic",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "wads-153", roomNumber: "Rm 153", title: "Residence Education and Housing Services", subtitle: "Campus Housing, Meal Plans & Room Assignments • Wads 153", roleBadge: "Campus Housing", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2682", email: "housing@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32)),
                        MTUFloorRoom(id: "wads-110", roomNumber: "Rm 110", title: "Wadsworth Dining Hall", subtitle: "East Campus Residential Dining Commons", roleBadge: "Dining Hall", officeHours: "Open 7:00 AM – 8:00 PM", phone: "906-487-2682", email: "dining@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 9. McAllister Welcome Center (Bldg #107) — Undergraduate Admissions
        // =========================================================================
        MTUBuilding(
            id: "mcallister",
            name: "McAllister Welcome Center",
            shortName: "Welcome Center",
            buildingNumber: 107,
            category: .studentSupport,
            latitude: 47.1185,
            longitude: -88.5487,
            primaryHighlight: "Undergraduate Admissions • Main Suite",
            secondaryHighlight: "Campus Tours & Prospective Student Center",
            openHoursText: "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 2,
            walkMinutesIndoor: 2,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Across Townsend Drive south of MUB & Administration Building (2 min walk)",
            phone: "906-487-2335",
            email: "admissions@mtu.edu",
            officialURL: "https://www.mtu.edu/admissions/",
            matchingOfficePrefixes: ["McAllister", "Welcome Center"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Undergraduate Admissions & Tour Welcome Lobby",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "mcallister-101", roomNumber: "Rm 101", title: "Undergraduate Admissions", subtitle: "McAllister Welcome Center • Admissions & Campus Visits", roleBadge: "Admissions Office", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2335", email: "admissions@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.34), doorwayPoint: CGPoint(x: 0.59, y: 0.33)),
                        MTUFloorRoom(id: "mcallister-110", roomNumber: "Rm 110", title: "Husky Tour Presentation Hall", subtitle: "Daily Campus Tour Departure Lounge", roleBadge: "Visitor Lounge", officeHours: "Tours at 10:00 AM & 1:00 PM", phone: "906-487-2335", email: "admissions@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 10. Widmaier House (Bldg #96) — Public Safety and Police Services
        // =========================================================================
        MTUBuilding(
            id: "widmaier",
            name: "Widmaier House (Public Safety & Police)",
            shortName: "Public Safety",
            buildingNumber: 96,
            category: .studentSupport,
            latitude: 47.1180,
            longitude: -88.5492,
            primaryHighlight: "Public Safety and Police Services • 206 MacInnes Dr.",
            secondaryHighlight: "24/7 Campus Dispatch, Escort Service & Lost and Found",
            openHoursText: "Open 24 Hours • 24/7 Emergency Support",
            isOpenNow: true,
            walkMinutesOutdoor: 3,
            walkMinutesIndoor: 3,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Located at 206 MacInnes Drive, just south of McAllister Welcome Center (3 min walk)",
            phone: "906-487-2216",
            email: "psps@mtu.edu",
            officialURL: "https://www.mtu.edu/publicsafety/",
            matchingOfficePrefixes: ["Widmaier", "MacInnes", "Public Safety"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Campus Police Headquarters & 24/7 Dispatch",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "widmaier-101", roomNumber: "Rm 101", title: "Public Safety and Police Services", subtitle: "Widmaier House, 206 MacInnes Dr. • Non-Emergency & Safety", roleBadge: "Campus Safety", officeHours: "Open 24 Hours", phone: "906-487-2216", email: "psps@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.34), doorwayPoint: CGPoint(x: 0.59, y: 0.33))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 11. Student Development Complex (SDC • Bldg #24) — Athletics & Recreation
        // =========================================================================
        MTUBuilding(
            id: "sdc",
            name: "Student Development Complex (SDC)",
            shortName: "SDC • Athletics",
            buildingNumber: 24,
            category: .transitDining,
            latitude: 47.1145,
            longitude: -88.5476,
            primaryHighlight: "Student Development Complex Main Office • Rm 100",
            secondaryHighlight: "MacInnes Ice Arena, Fitness Center & Varsity Pool",
            openHoursText: "Open Now • 6:00 AM – 10:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 8,
            walkMinutesIndoor: 7,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Walk south up MacInnes Drive past Widmaier House or ride Husky Shuttle (8 min)",
            phone: "906-487-2578",
            email: "sdc@mtu.edu",
            officialURL: "https://www.michigantechhuskies.com/",
            matchingOfficePrefixes: ["Student Development Complex", "SDC"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • SDC Main Office, Ice Arena & Fitness Center",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "sdc-100", roomNumber: "Rm 100", title: "Student Development Complex (SDC)", subtitle: "Athletics, Recreation & Ticket Central • SDC Main Concourse", roleBadge: "Athletics & Rec", officeHours: "Open Now • 6:00 AM – 10:00 PM", phone: "906-487-2578", email: "sdc@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.32), doorwayPoint: CGPoint(x: 0.59, y: 0.32)),
                        MTUFloorRoom(id: "sdc-120", roomNumber: "Arena", title: "John MacInnes Student Ice Arena", subtitle: "MTU Huskies Hockey & Open Skate • SDC West Wing", roleBadge: "Ice Arena", officeHours: "Event & Rec Hours", phone: "906-487-2073", email: "sdc@mtu.edu", rect: CGRect(x: 0.08, y: 0.18, width: 0.25, height: 0.30), doorwayPoint: CGPoint(x: 0.33, y: 0.33))
                    ]
                )
            ]
        ),
        
        // =========================================================================
        // 12. Lakeshore Center (Bldg #100) — Human Resources Office (2nd Floor)
        // =========================================================================
        MTUBuilding(
            id: "lakeshore",
            name: "Lakeshore Center",
            shortName: "Lakeshore Center",
            buildingNumber: 100,
            category: .studentSupport,
            latitude: 47.1214,
            longitude: -88.5562,
            primaryHighlight: "Human Resources Office • 2nd Floor (Rm 200)",
            secondaryHighlight: "Student Employment, Payroll & Sponsored Programs",
            openHoursText: "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 9,
            walkMinutesIndoor: 8,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Take City/Husky Shuttle west along Lakeshore Drive or walk via Waterfront Trail",
            phone: "906-487-2280",
            email: "hr-help@mtu.edu",
            officialURL: "https://www.mtu.edu/hr/",
            matchingOfficePrefixes: ["Lakeshore Center"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Waterfront Lobby & Enterprise Suites",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "lakeshore-100", roomNumber: "Rm 100", title: "Lakeshore Main Lobby & Innovation Hub", subtitle: "Waterfront Atrium • Lakeshore Center 1F", roleBadge: "Atrium Hub", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2280", email: "hr-help@mtu.edu", rect: CGRect(x: 0.59, y: 0.18, width: 0.27, height: 0.30), doorwayPoint: CGPoint(x: 0.59, y: 0.33))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Human Resources, Payroll & Student Employment",
                    elevatorPoint: CGPoint(x: 0.45, y: 0.78),
                    hallwaySpineX: 0.56,
                    rooms: [
                        MTUFloorRoom(id: "lakeshore-200", roomNumber: "2nd Fl", title: "Human Resources Office", subtitle: "Lakeshore Center, 2nd Floor • Student Jobs, I-9 & Benefits", roleBadge: "Human Resources", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2280", email: "hr-help@mtu.edu", rect: CGRect(x: 0.59, y: 0.16, width: 0.27, height: 0.34), doorwayPoint: CGPoint(x: 0.59, y: 0.33))
                    ]
                )
            ]
        )
    ]
    
    /// Finds the exact matching MTUBuilding, floorCode, and MTUFloorRoom for ANY Contact in contacts.json
    static func matchBuilding(for contact: Contact) -> (building: MTUBuilding, floorCode: String?, room: MTUFloorRoom?)? {
        guard let office = contact.office else { return nil }
        for building in buildings {
            if building.matchingOfficePrefixes.contains(where: { office.localizedCaseInsensitiveContains($0) }) {
                // 1. Try matching by exact person/office name or email first (handles shared suites like Admin 130 or Rekhi 322)
                for floor in building.floors {
                    if let nameOrEmailMatch = floor.rooms.first(where: {
                        $0.email.caseInsensitiveCompare(contact.email) == .orderedSame ||
                        $0.title.localizedCaseInsensitiveContains(contact.name) ||
                        contact.name.localizedCaseInsensitiveContains($0.title) ||
                        $0.subtitle.localizedCaseInsensitiveContains(contact.name)
                    }) {
                        return (building, floor.levelCode, nameOrEmailMatch)
                    }
                }
                // 2. Match by exact room token (e.g. "322", "G002", "103", "2nd Fl", "1st Fl")
                for floor in building.floors {
                    if let roomMatch = floor.rooms.first(where: { room in
                        let cleanNum = room.roomNumber
                            .replacingOccurrences(of: "Rm ", with: "")
                            .trimmingCharacters(in: .whitespaces)
                        return office.localizedCaseInsensitiveContains(cleanNum)
                    }) {
                        return (building, floor.levelCode, roomMatch)
                    }
                }
                // 3. Infer floor code from 3-digit room number if present
                if let digits = office.components(separatedBy: CharacterSet.decimalDigits.inverted).first(where: { $0.count == 3 }),
                   let firstChar = digits.first {
                    let floorCode = "\(firstChar)F"
                    if let floor = building.floors.first(where: { $0.levelCode == floorCode }) {
                        return (building, floor.levelCode, floor.rooms.first)
                    }
                }
                let fallbackFloor = building.floors.first
                return (building, fallbackFloor?.levelCode, fallbackFloor?.rooms.first)
            }
        }
        return nil
    }
}
