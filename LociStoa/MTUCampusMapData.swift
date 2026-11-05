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
}

struct MTUFloorLevel: Identifiable, Hashable {
    var id: String { levelCode }
    let levelCode: String       // "1F", "2F", "3F"
    let levelTitle: String      // e.g., "3rd Floor • Computer Science Faculty"
    let elevatorPoint: CGPoint  // Normalized start point for indoor route
    let hallwaySpineX: CGFloat  // Normalized hallway X coordinate
    let rooms: [MTUFloorRoom]
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

// MARK: - Winter Skywalk & Shuttle Models
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

// MARK: - Verified MTU Campus Dataset
enum MTUCampusData {
    static let campusCenter = CLLocationCoordinate2D(latitude: 47.1191, longitude: -88.5473)
    
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
            title: "MUB → EERC Heated Corridor Route",
            fromCoord: CLLocationCoordinate2D(latitude: 47.1192, longitude: -88.5494),
            toCoord: CLLocationCoordinate2D(latitude: 47.1189, longitude: -88.5458)
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
    
    static let buildings: [MTUBuilding] = [
        // 1. Rekhi Hall
        MTUBuilding(
            id: "rekhi",
            name: "Kanwal and Ann Rekhi Hall",
            shortName: "Rekhi Hall",
            buildingNumber: 28,
            category: .facultyOffices,
            latitude: 47.1189,
            longitude: -88.5458,
            primaryHighlight: "Waino/CCLC Tutoring • Rm 209",
            secondaryHighlight: "CS Dept & Advising • Rm 322",
            openHoursText: "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 4,
            walkMinutesIndoor: 3,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Take MUB Skywalk → Library 1st Floor → Rekhi Hall (3 min indoor walk, avoids snow)",
            phone: "906-487-2209",
            email: "cs@mtu.edu",
            officialURL: "https://www.mtu.edu/cs/",
            matchingOfficePrefixes: ["Rekhi"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Computing Labs & Faculty",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "rekhi-102", roomNumber: "Rm 102", title: "Stella Otoo", subtitle: "Computer Science • Rekhi Hall 102", roleBadge: "Teaching Prof", officeHours: "Open until 3:30 PM", phone: "906-487-3602", email: "sotoo@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.18), doorwayPoint: CGPoint(x: 0.54, y: 0.23)),
                        MTUFloorRoom(id: "rekhi-103", roomNumber: "Rm 103", title: "Todd O. Arney", subtitle: "Applied Computing • Rekhi Hall 103", roleBadge: "IT Program Dir", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-1085", email: "toarney@mtu.edu", rect: CGRect(x: 0.54, y: 0.35, width: 0.34, height: 0.18), doorwayPoint: CGPoint(x: 0.54, y: 0.44)),
                        MTUFloorRoom(id: "rekhi-104", roomNumber: "Rm 104", title: "Serein Al-Ratrout", subtitle: "Computer Science • Rekhi Hall 104", roleBadge: "Assoc Teaching Prof", officeHours: "Tue/Thu 2:00–4:00 PM", phone: "906-487-2518", email: "salratro@mtu.edu", rect: CGRect(x: 0.54, y: 0.56, width: 0.34, height: 0.20), doorwayPoint: CGPoint(x: 0.54, y: 0.66)),
                        MTUFloorRoom(id: "rekhi-110", roomNumber: "Rm 110", title: "Dr. Yu Cai", subtitle: "College of Computing • Rekhi Hall 110", roleBadge: "Associate Dean", officeHours: "By Appointment", phone: "906-487-1471", email: "cai@mtu.edu", rect: CGRect(x: 0.12, y: 0.14, width: 0.28, height: 0.24), doorwayPoint: CGPoint(x: 0.40, y: 0.26))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • CCLC Learning Center & Dean",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "rekhi-209", roomNumber: "Rm 209", title: "CCLC Tutoring & Dr. Leo Ureel II", subtitle: "CS Learning Center • Rekhi Hall 209", roleBadge: "Learning Center", officeHours: "Open Now • Walk-in Tutoring", phone: "906-487-1816", email: "ureel@mtu.edu", rect: CGRect(x: 0.54, y: 0.12, width: 0.34, height: 0.20), doorwayPoint: CGPoint(x: 0.54, y: 0.22)),
                        MTUFloorRoom(id: "rekhi-211", roomNumber: "Rm 211", title: "Dr. Briana Bettin", subtitle: "Computer Science • Rekhi Hall 211", roleBadge: "Associate Prof", officeHours: "Open until 4:00 PM", phone: "906-487-1833", email: "bcbettin@mtu.edu", rect: CGRect(x: 0.54, y: 0.34, width: 0.34, height: 0.18), doorwayPoint: CGPoint(x: 0.54, y: 0.43)),
                        MTUFloorRoom(id: "rekhi-221", roomNumber: "Rm 221", title: "Dr. Dennis Livesay", subtitle: "College of Computing • Rekhi Hall 221", roleBadge: "Dean of Computing", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2316", email: "dlivesay@mtu.edu", rect: CGRect(x: 0.54, y: 0.55, width: 0.34, height: 0.22), doorwayPoint: CGPoint(x: 0.54, y: 0.66)),
                        MTUFloorRoom(id: "rekhi-214", roomNumber: "Rm 214", title: "Rekhi 214 Lecture Hall", subtitle: "Main Computing Classroom • 2nd Floor", roleBadge: "Classroom", officeHours: "Next Class: 10:13 – 11:07", phone: "906-487-2209", email: "cs@mtu.edu", rect: CGRect(x: 0.12, y: 0.12, width: 0.28, height: 0.30), doorwayPoint: CGPoint(x: 0.40, y: 0.27))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • CS Advising & Department Office",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "rekhi-322", roomNumber: "Rm 322", title: "Denise Landsberg", subtitle: "Computer Science • Rekhi Hall 322", roleBadge: "Academic Advisor", officeHours: "Open until 4:00 PM", phone: "906-487-3643", email: "dllandsb@mtu.edu", rect: CGRect(x: 0.54, y: 0.12, width: 0.34, height: 0.19), doorwayPoint: CGPoint(x: 0.54, y: 0.21)),
                        MTUFloorRoom(id: "rekhi-310", roomNumber: "Rm 310", title: "Dr. Koloud Al Khamaiseh", subtitle: "Computer Science • Rekhi Hall 310", roleBadge: "Teaching Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-3619", email: "kalkhama@mtu.edu", rect: CGRect(x: 0.54, y: 0.33, width: 0.34, height: 0.17), doorwayPoint: CGPoint(x: 0.54, y: 0.41)),
                        MTUFloorRoom(id: "rekhi-308", roomNumber: "Rm 308", title: "Dr. Gorkem Asilioglu", subtitle: "Computer Science • Rekhi Hall 308", roleBadge: "Assoc Teaching Prof", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-1643", email: "galolu@mtu.edu", rect: CGRect(x: 0.54, y: 0.52, width: 0.34, height: 0.17), doorwayPoint: CGPoint(x: 0.54, y: 0.60)),
                        MTUFloorRoom(id: "rekhi-301", roomNumber: "Rm 301", title: "Dr. Bo Chen", subtitle: "Cybersecurity Director • Rekhi Hall 301", roleBadge: "Associate Prof", officeHours: "Wed/Fri 10:00–12:00 PM", phone: "906-487-3149", email: "bchen@mtu.edu", rect: CGRect(x: 0.54, y: 0.71, width: 0.34, height: 0.19), doorwayPoint: CGPoint(x: 0.54, y: 0.80)),
                        MTUFloorRoom(id: "rekhi-309", roomNumber: "Rm 309", title: "Dr. Nilufer Onder", subtitle: "Undergrad Program Dir • Rekhi Hall 309", roleBadge: "Program Director", officeHours: "Open until 3:30 PM", phone: "906-487-1641", email: "nilufer@mtu.edu", rect: CGRect(x: 0.12, y: 0.12, width: 0.28, height: 0.22), doorwayPoint: CGPoint(x: 0.40, y: 0.23))
                    ]
                )
            ]
        ),
        
        // 2. Administration Building
        MTUBuilding(
            id: "admin",
            name: "Administration Building",
            shortName: "Admin Building",
            buildingNumber: 1,
            category: .studentSupport,
            latitude: 47.1195,
            longitude: -88.5482,
            primaryHighlight: "Waino Wahtera Center for Student Success • Admin Bldg 130",
            secondaryHighlight: "Career Services • Rm 220",
            openHoursText: "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 3,
            walkMinutesIndoor: 3,
            hasSkywalkAccess: false,
            skywalkRouteSummary: "Take MUB Skywalk exit → 1 min cleared plaza walk to Admin Entrance",
            phone: "906-487-3558",
            email: "success@mtu.edu",
            officialURL: "https://www.mtu.edu/success/",
            matchingOfficePrefixes: ["Administration Building"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Student Success, Registrar & Financial Aid",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "admin-130", roomNumber: "Rm 130", title: "Waino Wahtera Center for Student Success", subtitle: "Registrar, Dean of Students & Disability Services • Admin 130", roleBadge: "Student Success", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-3558", email: "success@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.27)),
                        MTUFloorRoom(id: "admin-103", roomNumber: "Rm 103", title: "Student Financial Services & Financial Aid", subtitle: "Billing, Scholarships & Loans • Admin 103", roleBadge: "Financial Aid", officeHours: "Open Now • 8:00 AM – 4:30 PM", phone: "906-487-2622", email: "finaid@mtu.edu", rect: CGRect(x: 0.54, y: 0.44, width: 0.34, height: 0.22), doorwayPoint: CGPoint(x: 0.54, y: 0.55)),
                        MTUFloorRoom(id: "admin-100", roomNumber: "Rm 100", title: "Transportation & Parking Services", subtitle: "Permits & Shuttle Passes • Admin 100", roleBadge: "Parking & Transit", officeHours: "Open 8:00 AM – 4:30 PM", phone: "906-487-1441", email: "parking@mtu.edu", rect: CGRect(x: 0.12, y: 0.14, width: 0.28, height: 0.24), doorwayPoint: CGPoint(x: 0.40, y: 0.26))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Career Services & International Programs",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "admin-220", roomNumber: "Rm 220", title: "Career Services", subtitle: "Career Fair Prep, Co-ops & Resume Reviews • Admin 220", roleBadge: "Career Advising", officeHours: "Open Now • Drop-in Hours", phone: "906-487-2313", email: "career@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.28), doorwayPoint: CGPoint(x: 0.54, y: 0.30)),
                        MTUFloorRoom(id: "admin-200", roomNumber: "Rm 200", title: "International Programs and Services", subtitle: "Global Campus & Study Abroad • Admin 200", roleBadge: "International", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2160", email: "ips@mtu.edu", rect: CGRect(x: 0.54, y: 0.48, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.61))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • Student Mental Health & Graduate School",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "admin-301", roomNumber: "Rm 301", title: "Center for Student Mental Health & Well-being", subtitle: "Counseling & Wellness • Admin 301", roleBadge: "Health & Wellness", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-2538", email: "counseling@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31)),
                        MTUFloorRoom(id: "admin-414", roomNumber: "Rm 414", title: "Graduate School Office", subtitle: "Graduate Programs & Research • Admin 414", roleBadge: "Grad School", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2327", email: "gradschool@mtu.edu", rect: CGRect(x: 0.54, y: 0.50, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.63))
                    ]
                )
            ]
        ),
        
        // 3. Van Pelt and Opie Library
        MTUBuilding(
            id: "library",
            name: "Van Pelt and Opie Library",
            shortName: "Van Pelt & Opie Library",
            buildingNumber: 17,
            category: .learningCenters,
            latitude: 47.1187,
            longitude: -88.5469,
            primaryHighlight: "IT Service Center & HuskyCard • Rm 101",
            secondaryHighlight: "24/7 Study Commons & Writing Center • 1st Floor",
            openHoursText: "Open 24 Hours • IT Desk until 6:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 3,
            walkMinutesIndoor: 2,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Direct Skywalk from MUB 2nd Floor → Library Main Concourse (2 min indoor walk)",
            phone: "906-487-2508",
            email: "library@mtu.edu",
            officialURL: "https://www.mtu.edu/library/",
            matchingOfficePrefixes: ["Van Pelt", "Library"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • IT Helpdesk, Café & Service Center",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "lib-101", roomNumber: "Rm 101", title: "IT Service Center & HuskyCard", subtitle: "Tech Support, Wi-Fi & HuskyCard ID • Library 101", roleBadge: "IT Support", officeHours: "Open Now • 8:00 AM – 6:00 PM", phone: "906-487-1111", email: "it-help@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.28), doorwayPoint: CGPoint(x: 0.54, y: 0.28)),
                        MTUFloorRoom(id: "lib-svc", roomNumber: "1st Fl", title: "Library Service Center", subtitle: "Course Reserves, Printing & Study Rooms", roleBadge: "Library Desk", officeHours: "Open 24 Hours", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.54, y: 0.46, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.59))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Collaborative Study & Skywalk Bridge",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "lib-201", roomNumber: "Rm 201", title: "Group Study Suites", subtitle: "Whiteboard & Display Pods • 2nd Floor East", roleBadge: "Study Space", officeHours: "Reservable 24/7", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • Quiet Study & Archives",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "lib-301", roomNumber: "Rm 301", title: "Silent Reading Room", subtitle: "Portage Lake Overlook Study Zone", roleBadge: "Quiet Zone", officeHours: "Open 24 Hours", phone: "906-487-2508", email: "library@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                )
            ]
        ),
        
        // 4. Electrical Energy Resources Center (EERC)
        MTUBuilding(
            id: "eerc",
            name: "Electrical Energy Resources Center",
            shortName: "EERC",
            buildingNumber: 7,
            category: .facultyOffices,
            latitude: 47.1185,
            longitude: -88.5447,
            primaryHighlight: "ECE Dept Office • Rm 121",
            secondaryHighlight: "The Alley Makerspace • Rm 518",
            openHoursText: "Open Now • 7:00 AM – 10:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 5,
            walkMinutesIndoor: 4,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Take MUB Skywalk → Library → Rekhi Hall → EERC Connector (4 min indoor walk)",
            phone: "906-487-2550",
            email: "ece@mtu.edu",
            officialURL: "https://www.mtu.edu/ece/",
            matchingOfficePrefixes: ["EERC"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • ECE Main Office & Labs",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "eerc-121", roomNumber: "Rm 121", title: "Dr. Wayne W. Weaver", subtitle: "Electrical & Computer Engineering • EERC 121", roleBadge: "ECE Dept Chair", officeHours: "Open until 4:30 PM", phone: "906-487-1461", email: "wwweaver@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.27)),
                        MTUFloorRoom(id: "eerc-234", roomNumber: "Rm 234", title: "Dr. Aurenice M. Oliveira", subtitle: "ECE Grad Studies Director • EERC 234", roleBadge: "Associate Chair", officeHours: "Tue/Thu 1:30–3:30 PM", phone: "906-487-2494", email: "oliveira@mtu.edu", rect: CGRect(x: 0.54, y: 0.44, width: 0.34, height: 0.24), doorwayPoint: CGPoint(x: 0.54, y: 0.56))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "4th & 5th Floors • Applied Computing & Makerspace",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "eerc-518", roomNumber: "Rm 518", title: "Dr. Shane Oberloier", subtitle: "The Alley Makerspace Director • EERC 518", roleBadge: "Makerspace", officeHours: "Open Now • Prototyping Lab", phone: "906-487-2941", email: "swoberlo@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.24), doorwayPoint: CGPoint(x: 0.54, y: 0.26)),
                        MTUFloorRoom(id: "eerc-520", roomNumber: "Rm 520", title: "Christopher (Kit) Cischke", subtitle: "ECE Undergraduate Advising • EERC 520", roleBadge: "Associate Chair", officeHours: "Open until 4:00 PM", phone: "906-487-2011", email: "cmcischk@mtu.edu", rect: CGRect(x: 0.54, y: 0.42, width: 0.34, height: 0.24), doorwayPoint: CGPoint(x: 0.54, y: 0.54)),
                        MTUFloorRoom(id: "eerc-413", roomNumber: "Rm 413", title: "Dr. Aleksandr Sergeyev", subtitle: "Applied Computing • EERC 413", roleBadge: "Grad Program Dir", officeHours: "Mon/Wed 2:00–4:00 PM", phone: "906-487-2258", email: "avsergue@mtu.edu", rect: CGRect(x: 0.12, y: 0.14, width: 0.28, height: 0.26), doorwayPoint: CGPoint(x: 0.40, y: 0.27))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "6th & 7th Floors • Senior Design & Power Systems",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "eerc-731", roomNumber: "Rm 731", title: "Dr. Anthony (Tony) Pinar", subtitle: "Senior Design Coordinator • EERC 731", roleBadge: "Senior Design", officeHours: "Open until 4:00 PM", phone: "906-487-0024", email: "ajpinar@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.29)),
                        MTUFloorRoom(id: "eerc-630", roomNumber: "Rm 630", title: "Dr. Paul L. Bergstrom", subtitle: "Electrical Engineering • EERC 630", roleBadge: "Professor", officeHours: "Tue/Thu 10:00–12:00 PM", phone: "906-487-2058", email: "paulb@mtu.edu", rect: CGRect(x: 0.54, y: 0.46, width: 0.34, height: 0.26), doorwayPoint: CGPoint(x: 0.54, y: 0.59))
                    ]
                )
            ]
        ),
        
        // 5. Memorial Union Building (MUB)
        MTUBuilding(
            id: "mub",
            name: "Memorial Union Building (MUB)",
            shortName: "MUB",
            buildingNumber: 34,
            category: .transitDining,
            latitude: 47.1192,
            longitude: -88.5494,
            primaryHighlight: "Student Leadership & Involvement • Rm 112",
            secondaryHighlight: "Husky Den Food Court & Skywalk Hub",
            openHoursText: "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow: true,
            walkMinutesOutdoor: 2,
            walkMinutesIndoor: 1,
            hasSkywalkAccess: true,
            skywalkRouteSummary: "Central Skywalk Hub connecting directly to Van Pelt Library & East Campus",
            phone: "906-487-1963",
            email: "activities@mtu.edu",
            officialURL: "https://www.mtu.edu/union/",
            matchingOfficePrefixes: ["Memorial Union"],
            floors: [
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Student Leadership & Campus Store",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "mub-112", roomNumber: "Rm 112", title: "Student Leadership and Involvement", subtitle: "Student Orgs, Greek Life & Events • MUB 112", roleBadge: "Student Affairs", officeHours: "Open Now • 8:00 AM – 5:00 PM", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Food Court, Lounge & Library Skywalk",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "mub-sky", roomNumber: "Skywalk", title: "MUB → Library Heated Skywalk Entrance", subtitle: "Indoor Bridge over Townsend Drive", roleBadge: "Winter Route", officeHours: "Open 24 Hours", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • Ballroom & Conference Suites",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "mub-ballroom", roomNumber: "Rm 300", title: "MUB Ballroom", subtitle: "Career Fair & Campus Event Venue", roleBadge: "Event Space", officeHours: "Event Hours", phone: "906-487-1963", email: "activities@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                )
            ]
        ),
        
        // 6. Great Lakes Research Center (GLRC)
        MTUBuilding(
            id: "glrc",
            name: "Great Lakes Research Center",
            shortName: "GLRC",
            buildingNumber: 102,
            category: .learningCenters,
            latitude: 47.1205,
            longitude: -88.5452,
            primaryHighlight: "GLRC Director & AI Labs • Rm 307",
            secondaryHighlight: "Data Science & Computing • Rm 211",
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
                    levelTitle: "1st Floor • Marine & Autonomous Vessels Lab",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "glrc-101", roomNumber: "Rm 101", title: "Boathouse & Waterfront Lab", subtitle: "Portage Lake Research Dock • GLRC 1F", roleBadge: "Research Lab", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-3115", email: "thavens@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "2F",
                    levelTitle: "2nd Floor • Data Science & Sensing",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "glrc-211", roomNumber: "Rm 211", title: "Dr. Evan Lucas", subtitle: "Data Science & Computer Science • GLRC 211", roleBadge: "Assistant Prof", officeHours: "Mon/Wed 1:00–3:00 PM", phone: "906-487-2094", email: "eglucas@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                ),
                MTUFloorLevel(
                    levelCode: "3F",
                    levelTitle: "3rd Floor • GLRC Executive Suite",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "glrc-307", roomNumber: "Rm 307", title: "Dr. Timothy C. Havens", subtitle: "GLRC Executive Director & CS Prof • GLRC 307", roleBadge: "Director", officeHours: "Open until 4:30 PM", phone: "906-487-3115", email: "thavens@mtu.edu", rect: CGRect(x: 0.54, y: 0.16, width: 0.34, height: 0.30), doorwayPoint: CGPoint(x: 0.54, y: 0.31))
                    ]
                )
            ]
        ),
        
        // 7. Academic Office Building (AOB)
        MTUBuilding(
            id: "aob",
            name: "Academic Office Building (College of Business)",
            shortName: "AOB • Business",
            buildingNumber: 5,
            category: .facultyOffices,
            latitude: 47.1198,
            longitude: -88.5508,
            primaryHighlight: "Business Advising (Ryan Neely) • Rm 108",
            secondaryHighlight: "Dean's Suite (Dr. Sri Beldona) • Rm 103",
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
                MTUFloorLevel(
                    levelCode: "1F",
                    levelTitle: "1st Floor • Business Dean & Advising Suite",
                    elevatorPoint: CGPoint(x: 0.30, y: 0.78),
                    hallwaySpineX: 0.46,
                    rooms: [
                        MTUFloorRoom(id: "aob-108", roomNumber: "Rm 108", title: "Ryan Neely", subtitle: "College of Business • AOB 108", roleBadge: "Academic Advisor", officeHours: "Open Now • Drop-in until 4:00 PM", phone: "906-487-3597", email: "rmneely@mtu.edu", rect: CGRect(x: 0.54, y: 0.14, width: 0.34, height: 0.22), doorwayPoint: CGPoint(x: 0.54, y: 0.25)),
                        MTUFloorRoom(id: "aob-103", roomNumber: "Rm 103", title: "Dr. Sri Beldona", subtitle: "Dean of College of Business • AOB 103", roleBadge: "Dean", officeHours: "Open 8:00 AM – 5:00 PM", phone: "906-487-2668", email: "sbeldona@mtu.edu", rect: CGRect(x: 0.54, y: 0.40, width: 0.34, height: 0.22), doorwayPoint: CGPoint(x: 0.54, y: 0.51)),
                        MTUFloorRoom(id: "aob-115", roomNumber: "Rm 115", title: "Dr. Dean Johnson", subtitle: "Professor of Finance & APMP Dir • AOB 115", roleBadge: "Finance Prof", officeHours: "Tue/Thu 1:00–3:00 PM", phone: "906-487-1450", email: "dean@mtu.edu", rect: CGRect(x: 0.54, y: 0.66, width: 0.34, height: 0.22), doorwayPoint: CGPoint(x: 0.54, y: 0.77))
                    ]
                )
            ]
        )
    ]
    
    /// Finds the matching MTUBuilding and optional room for any Contact from contacts.json
    static func matchBuilding(for contact: Contact) -> (building: MTUBuilding, floorCode: String?, room: MTUFloorRoom?)? {
        guard let office = contact.office else { return nil }
        for building in buildings {
            if building.matchingOfficePrefixes.contains(where: { office.localizedCaseInsensitiveContains($0) }) {
                // Check if a specific room matches
                for floor in building.floors {
                    if let matchedRoom = floor.rooms.first(where: {
                        office.localizedCaseInsensitiveContains($0.roomNumber.replacingOccurrences(of: "Rm ", with: "")) ||
                        $0.title.localizedCaseInsensitiveContains(contact.name)
                    }) {
                        return (building, floor.levelCode, matchedRoom)
                    }
                }
                // Infer floor code from 3-digit room number if present
                if let digits = office.components(separatedBy: CharacterSet.decimalDigits.inverted).first(where: { $0.count == 3 }),
                   let firstChar = digits.first {
                    let floorCode = "\(firstChar)F"
                    if building.floors.contains(where: { $0.levelCode == floorCode }) {
                        return (building, floorCode, nil)
                    }
                }
                return (building, building.floors.first?.levelCode, nil)
            }
        }
        return nil
    }
}
