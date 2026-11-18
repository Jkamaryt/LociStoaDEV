package com.locistoa.app.data

import androidx.compose.ui.graphics.Color
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

enum class MTULocationCategory(val rawValue: String) {
    ALL("All Campus"),
    LEARNING_CENTERS("Learning Centers"),
    FACULTY_OFFICES("Faculty Offices"),
    STUDENT_SUPPORT("Student Support"),
    TRANSIT_DINING("Dining & Shuttle");

    val tintColor: Color
        get() = when (this) {
            ALL -> Color(0xFF734FC2)
            LEARNING_CENTERS -> Color(0xFFE0751F)
            FACULTY_OFFICES -> Color(0xFF734FC2)
            STUDENT_SUPPORT -> Color(0xFF219487)
            TRANSIT_DINING -> Color(0xFF2E70D1)
        }
}

enum class MTURoomKind(val rawValue: String) {
    FACULTY_OFFICE("Faculty Office"),
    DEPARTMENT_HUB("Dept / Advising"),
    LEARNING_LAB("Lab / Classroom"),
    STUDENT_SUPPORT("Student Service"),
    CAMPUS_AMENITY("Commons / Event");

    val color: Color
        get() = when (this) {
            FACULTY_OFFICE -> Color(0xFF734FC2)   // Purple
            DEPARTMENT_HUB -> Color(0xFF1F7AD6)   // Blue
            LEARNING_LAB -> Color(0xFFE0751A)     // Amber
            STUDENT_SUPPORT -> Color(0xFF1F9973)  // Emerald
            CAMPUS_AMENITY -> Color(0xFFC7428A)   // Magenta
        }
}

data class NormalizedPoint(val x: Float, val y: Float)

data class NormalizedRect(
    val x: Float,
    val y: Float,
    val width: Float,
    val height: Float
) {
    val midX: Float get() = x + width / 2f
    val midY: Float get() = y + height / 2f
}

data class MTUFloorEntryPortal(
    val id: String,
    val label: String,
    val shortLabel: String,
    val iconKey: String,
    val point: NormalizedPoint,
    val referenceNote: String
)

enum class MTUFloorLandmarkKind(val rawValue: String) {
    ELEVATOR("Elevator"),
    STAIRS("Stairs"),
    RESTROOM("Restrooms"),
    WATER("Water Station"),
    SKYWALK("Skywalk / Tunnel"),
    ENTRANCE("Main Entrance"),
    LOUNGE("Study Lounge");

    val tint: Color
        get() = when (this) {
            ELEVATOR -> Color(0xFF734FC2)
            STAIRS -> Color(0xFF596175)
            RESTROOM -> Color(0xFF2985C7)
            WATER -> Color(0xFF1AA6D9)
            SKYWALK -> Color(0xFF387AEB)
            ENTRANCE -> Color(0xFF249E61)
            LOUNGE -> Color(0xFFD97A29)
        }
}

data class MTUFloorLandmark(
    val id: String,
    val title: String,
    val kind: MTUFloorLandmarkKind,
    val point: NormalizedPoint
)

data class MTUFloorRoom(
    val id: String,
    val roomNumber: String,
    val title: String,
    val subtitle: String,
    val roleBadge: String,
    val officeHours: String,
    val phone: String,
    val email: String,
    val rect: NormalizedRect,
    val doorwayPoint: NormalizedPoint
) {
    val kind: MTURoomKind
        get() {
            val lowerBadge = roleBadge.lowercase()
            val lowerTitle = title.lowercase()
            val lowerSub = subtitle.lowercase()
            return when {
                lowerBadge.contains("advisor") || lowerBadge.contains("chair") || lowerBadge.contains("dean") || lowerBadge.contains("director") || lowerTitle.contains("dept") -> MTURoomKind.DEPARTMENT_HUB
                lowerBadge.contains("learning") || lowerBadge.contains("classroom") || lowerBadge.contains("lab") || lowerBadge.contains("makerspace") || lowerBadge.contains("study") || lowerBadge.contains("quiet") || lowerSub.contains("lab") || lowerSub.contains("classroom") -> MTURoomKind.LEARNING_LAB
                lowerBadge.contains("support") || lowerBadge.contains("financial") || lowerBadge.contains("career") || lowerBadge.contains("health") || lowerBadge.contains("it ") || lowerBadge.contains("parking") || lowerBadge.contains("international") || lowerBadge.contains("grad") || lowerBadge.contains("housing") || lowerBadge.contains("safety") || lowerBadge.contains("admissions") || lowerBadge.contains("hr") || lowerBadge.contains("disability") || lowerBadge.contains("registrar") -> MTURoomKind.STUDENT_SUPPORT
                lowerBadge.contains("winter") || lowerBadge.contains("event") || lowerBadge.contains("dining") || lowerBadge.contains("store") || lowerBadge.contains("athletics") || lowerBadge.contains("library") -> MTURoomKind.CAMPUS_AMENITY
                else -> MTURoomKind.FACULTY_OFFICE
            }
        }

    val wingName: String
        get() = when {
            rect.midX < 0.36f -> "West Wing"
            rect.midX > 0.55f -> "East Wing"
            else -> "Central Core"
        }

    val relativeReferenceText: String
        get() {
            val verticalZone = when {
                rect.midY < 0.30f -> "North End (near North Stairwell)"
                rect.midY < 0.62f -> "Mid-Corridor (across from Central Core & Restrooms)"
                else -> "South End (near Main Elevator & Lobby)"
            }
            return "$wingName • $verticalZone"
        }
}

data class RouteSummaryInfo(
    val distanceFeet: Int,
    val seconds: Int,
    val steps: List<String>
)

data class MTUFloorLevel(
    val levelCode: String,
    val levelTitle: String,
    val elevatorPoint: NormalizedPoint,
    val hallwaySpineX: Float,
    val rooms: List<MTUFloorRoom>
) {
    val westHallwaySpineX: Float get() = 0.36f
    val northCrossHallY: Float get() = 0.22f
    val southCrossHallY: Float get() = 0.78f

    fun entryPortals(building: MTUBuilding): List<MTUFloorEntryPortal> {
        val portals = mutableListOf(
            MTUFloorEntryPortal(
                id = "elevator",
                label = "Central Elevator",
                shortLabel = "Elevator",
                iconKey = "elevator",
                point = elevatorPoint,
                referenceNote = "South-Central Core Elevator Bank"
            ),
            MTUFloorEntryPortal(
                id = "north-stairs",
                label = "North Stairwell",
                shortLabel = "N. Stairs",
                iconKey = "stairs",
                point = NormalizedPoint(0.45f, 0.16f),
                referenceNote = "North Core Stairwell by Restrooms"
            )
        )

        if (levelCode == "1F" || levelCode == "GF") {
            portals.add(
                0,
                MTUFloorEntryPortal(
                    id = "main-entrance",
                    label = "Main Entrance Doors",
                    shortLabel = "Main Door",
                    iconKey = "door",
                    point = NormalizedPoint(0.46f, 0.89f),
                    referenceNote = "South Main Plaza Entrance (${building.southReference})"
                )
            )
        }

        if (building.hasSkywalkAccess && (levelCode == "1F" || levelCode == "2F")) {
            portals.add(
                MTUFloorEntryPortal(
                    id = "skywalk-portal",
                    label = "Heated Skywalk / Tunnel",
                    shortLabel = "Skywalk",
                    iconKey = "snowflake",
                    point = NormalizedPoint(0.10f, 0.50f),
                    referenceNote = "Indoor Heated Connector (${building.westReference})"
                )
            )
        }

        return portals
    }

    fun landmarks(building: MTUBuilding): List<MTUFloorLandmark> {
        val items = mutableListOf(
            MTUFloorLandmark(id = "lm-elev", title = "Elevator", kind = MTUFloorLandmarkKind.ELEVATOR, point = elevatorPoint),
            MTUFloorLandmark(id = "lm-stairs-s", title = "South Stairs", kind = MTUFloorLandmarkKind.STAIRS, point = NormalizedPoint(elevatorPoint.x, min(0.87f, elevatorPoint.y + 0.08f))),
            MTUFloorLandmark(id = "lm-stairs-n", title = "North Stairs", kind = MTUFloorLandmarkKind.STAIRS, point = NormalizedPoint(0.45f, 0.16f)),
            MTUFloorLandmark(id = "lm-rest", title = "Restrooms", kind = MTUFloorLandmarkKind.RESTROOM, point = NormalizedPoint(0.45f, 0.38f)),
            MTUFloorLandmark(id = "lm-water", title = "Water / Refill", kind = MTUFloorLandmarkKind.WATER, point = NormalizedPoint(0.45f, 0.54f))
        )
        if (levelCode == "1F" || levelCode == "GF") {
            items.add(MTUFloorLandmark(id = "lm-door", title = "Main Lobby Entrance", kind = MTUFloorLandmarkKind.ENTRANCE, point = NormalizedPoint(0.46f, 0.90f)))
        }
        if (building.hasSkywalkAccess && (levelCode == "1F" || levelCode == "2F")) {
            items.add(MTUFloorLandmark(id = "lm-sky", title = "Skywalk Connector", kind = MTUFloorLandmarkKind.SKYWALK, point = NormalizedPoint(0.11f, 0.50f)))
        }
        return items
    }

    fun routeWaypoints(from: MTUFloorEntryPortal, to: MTUFloorRoom): List<NormalizedPoint> {
        val start = from.point
        val end = to.doorwayPoint
        val targetSpineX = if (end.x <= 0.43f) westHallwaySpineX else hallwaySpineX

        val pts = mutableListOf(start)

        if (start.x < 0.20f) {
            val entryCorridorPt = NormalizedPoint(westHallwaySpineX, start.y)
            pts.add(entryCorridorPt)
            if (abs(targetSpineX - westHallwaySpineX) > 0.04f) {
                val crossY = if (end.y < 0.50f) northCrossHallY else southCrossHallY
                pts.add(NormalizedPoint(westHallwaySpineX, crossY))
                pts.add(NormalizedPoint(targetSpineX, crossY))
            }
            pts.add(NormalizedPoint(targetSpineX, end.y))
            pts.add(end)
            return pts
        }

        val crossY = if (abs(start.y - northCrossHallY) < abs(start.y - southCrossHallY)) {
            start.y
        } else {
            southCrossHallY
        }

        if (abs(start.y - crossY) > 0.02f) {
            pts.add(NormalizedPoint(start.x, crossY))
        }
        pts.add(NormalizedPoint(targetSpineX, crossY))
        pts.add(NormalizedPoint(targetSpineX, end.y))
        pts.add(end)
        return pts
    }

    fun routeSummary(from: MTUFloorEntryPortal, to: MTUFloorRoom): RouteSummaryInfo {
        val pts = routeWaypoints(from, to)
        var totalNormDist = 0f
        for (i in 1 until pts.size) {
            val dx = pts[i].x - pts[i - 1].x
            val dy = pts[i].y - pts[i - 1].y
            totalNormDist += hypot(dx, dy)
        }
        val feet = max(35, (totalNormDist * 210f).roundToInt())
        val seconds = max(10, (feet / 4.2).roundToInt())

        val steps = mutableListOf<String>()
        if (levelCode != "1F" && levelCode != "GF" && from.id == "elevator") {
            val floorPrefix = levelTitle.split("•").firstOrNull()?.trim() ?: levelCode
            steps.add("Take Central Elevator or Stairs up to $levelCode ($floorPrefix)")
        } else {
            steps.add("Start at ${from.label} (${from.referenceNote})")
        }

        val corridorSide = if (to.doorwayPoint.x <= 0.43f) "West Corridor" else "East Main Corridor"
        val heading = if (to.doorwayPoint.y < from.point.y) "North" else "South"
        val passLandmark = if (to.doorwayPoint.y < 0.42f) "past Central Restrooms" else "along Main Hallway"
        steps.add("Walk $heading down $corridorSide ($feet ft) $passLandmark")

        val doorSide = if (to.rect.midX > to.doorwayPoint.x) "on your Right (East Wall)" else "on your Left (West Wall)"
        steps.add("Arrive at ${to.roomNumber} (${to.title}) $doorSide")

        return RouteSummaryInfo(distanceFeet = feet, seconds = seconds, steps = steps)
    }
}

data class LatLngCoord(val latitude: Double, val longitude: Double)

data class MTUBuilding(
    val id: String,
    val name: String,
    val shortName: String,
    val buildingNumber: Int,
    val category: MTULocationCategory,
    val latitude: Double,
    val longitude: Double,
    val primaryHighlight: String,
    val secondaryHighlight: String,
    val openHoursText: String,
    val isOpenNow: Boolean,
    val walkMinutesOutdoor: Int,
    val walkMinutesIndoor: Int,
    val hasSkywalkAccess: Boolean,
    val skywalkRouteSummary: String,
    val phone: String,
    val email: String,
    val officialURL: String,
    val matchingOfficePrefixes: List<String>,
    val floors: List<MTUFloorLevel>
) {
    val coordinate: LatLngCoord get() = LatLngCoord(latitude, longitude)

    val northReference: String
        get() = when (id) {
            "rekhi" -> "U.S. 41 & Portage Lake Overlook"
            "admin" -> "U.S. 41 & Lakeshore Center (#100)"
            "library" -> "Husky Statue Plaza & U.S. 41"
            "eerc" -> "U.S. 41 & GLRC Overpass"
            "mub" -> "U.S. 41 & College Ave"
            "glrc" -> "Portage Lake Waterway & Dock"
            "aob" -> "College Ave & West Campus"
            "wads" -> "Townsend Drive & East Campus"
            "mcallister" -> "Townsend Drive & Lot 27"
            "sdc" -> "MacInnes Drive & Upper Campus"
            "widmaier" -> "Townsend Drive & Admin Building"
            "lakeshore" -> "Portage Lake Waterfront Dock"
            else -> "Portage Lake / North Campus"
        }

    val southReference: String
        get() = when (id) {
            "rekhi" -> "Townsend Drive & Fisher Hall (#20)"
            "admin" -> "Townsend Drive & Central Plaza"
            "library" -> "Townsend Drive & Dow Building (#8)"
            "eerc" -> "Townsend Drive & ME-EM Building (#112)"
            "mub" -> "Townsend Drive Shuttle Hub"
            "glrc" -> "U.S. 41 Pedestrian Overpass to Library"
            "aob" -> "Townsend Drive West Sidewalk"
            "wads" -> "McNair Residence Hall & Hillside"
            "mcallister" -> "MacInnes Drive & Widmaier House"
            "sdc" -> "Gates Tennis Center & Ski Trails"
            "widmaier" -> "MacInnes Drive & SDC Arena (#24)"
            "lakeshore" -> "U.S. 41 & West Houghton"
            else -> "Townsend Drive Main Corridor"
        }

    val westReference: String
        get() = when (id) {
            "rekhi" -> "Van Pelt Library (#17 • Tunnel)"
            "admin" -> "MUB (#34) & AOB (#5)"
            "library" -> "MUB (#34 • Skywalk Bridge)"
            "eerc" -> "Rekhi Hall (#28 • Indoor Connector)"
            "mub" -> "Administration Building (#1)"
            "glrc" -> "Lakeshore Center (#100)"
            "aob" -> "ROTC Building & West Entry"
            "wads" -> "Daniell Heights & Campus Core"
            "mcallister" -> "Administration Building (#1)"
            "sdc" -> "Lot 24 & MacInnes Drive"
            "widmaier" -> "McAllister Welcome Center (#107)"
            "lakeshore" -> "Houghton Waterfront Trail"
            else -> "West Campus Core"
        }

    val eastReference: String
        get() = when (id) {
            "rekhi" -> "EERC (#7 • Indoor Walkway)"
            "admin" -> "MUB (#34) & Husky Plaza"
            "library" -> "Rekhi Hall (#28 • Tunnel)"
            "eerc" -> "Chem Sci (#19) & Wadsworth (#37)"
            "mub" -> "Van Pelt Library (#17 • Skywalk)"
            "glrc" -> "U.S. Coast Guard Dock"
            "aob" -> "Administration Building (#1)"
            "wads" -> "East Campus Residence Loop"
            "mcallister" -> "Van Pelt Library South Lawn"
            "sdc" -> "Sherman Field & Ice Arena"
            "widmaier" -> "ROTC & Academic Core"
            "lakeshore" -> "GLRC (#102) Waterfront"
            else -> "East Campus Core"
        }

    val relativeCampusDescription: String
        get() = "Bldg #$buildingNumber • West: $westReference • East: $eastReference"
}

data class MTUCampusLandmark(
    val id: String,
    val name: String,
    val subtitle: String,
    val coordinate: LatLngCoord
)

data class MTUSkywalkSegment(
    val id: String,
    val title: String,
    val fromCoord: LatLngCoord,
    val toCoord: LatLngCoord
)

data class MTUShuttleStop(
    val id: String,
    val name: String,
    val routeName: String,
    val etaMinutes: Int,
    val coordinate: LatLngCoord
)

data class BuildingRoomMatch(
    val building: MTUBuilding,
    val floorCode: String?,
    val room: MTUFloorRoom?
)

object MTUCampusData {
    val campusCenter = LatLngCoord(latitude = 47.1189, longitude = -88.5472)

    val campusLandmarks: List<MTUCampusLandmark> = listOf(
        MTUCampusLandmark(
            id = "husky-plaza",
            name = "The Husky Statue Plaza",
            subtitle = "Central Quad Anchor • Between Library & Rekhi",
            coordinate = LatLngCoord(latitude = 47.1188, longitude = -88.5463)
        ),
        MTUCampusLandmark(
            id = "us41-overpass",
            name = "U.S. 41 Pedestrian Overpass",
            subtitle = "Bridge to GLRC Waterfront",
            coordinate = LatLngCoord(latitude = 47.1197, longitude = -88.5458)
        ),
        MTUCampusLandmark(
            id = "portage-waterfront",
            name = "Portage Lake Waterway",
            subtitle = "North Shoreline Orientation Reference",
            coordinate = LatLngCoord(latitude = 47.1211, longitude = -88.5468)
        ),
        MTUCampusLandmark(
            id = "townsend-corridor",
            name = "Townsend Drive Circle",
            subtitle = "Main South Campus Road & Shuttle Loop",
            coordinate = LatLngCoord(latitude = 47.1181, longitude = -88.5478)
        )
    )

    val skywalkSegments: List<MTUSkywalkSegment> = listOf(
        MTUSkywalkSegment(
            id = "sky-1",
            title = "MUB → Van Pelt Library Skywalk",
            fromCoord = LatLngCoord(latitude = 47.1192, longitude = -88.5494),
            toCoord = LatLngCoord(latitude = 47.1187, longitude = -88.5469)
        ),
        MTUSkywalkSegment(
            id = "sky-2",
            title = "Van Pelt Library → Rekhi Hall Tunnel/Connector",
            fromCoord = LatLngCoord(latitude = 47.1187, longitude = -88.5469),
            toCoord = LatLngCoord(latitude = 47.1189, longitude = -88.5458)
        ),
        MTUSkywalkSegment(
            id = "sky-3",
            title = "Rekhi Hall → EERC Indoor Walkway",
            fromCoord = LatLngCoord(latitude = 47.1189, longitude = -88.5458),
            toCoord = LatLngCoord(latitude = 47.1185, longitude = -88.5447)
        ),
        MTUSkywalkSegment(
            id = "sky-4",
            title = "Library North Exit → U.S. 41 Overpass → GLRC",
            fromCoord = LatLngCoord(latitude = 47.1187, longitude = -88.5469),
            toCoord = LatLngCoord(latitude = 47.1205, longitude = -88.5452)
        )
    )

    val shuttleStops: List<MTUShuttleStop> = listOf(
        MTUShuttleStop(
            id = "stop-mub",
            name = "MUB Husky Shuttle Hub",
            routeName = "Campus Core Loop",
            etaMinutes = 2,
            coordinate = LatLngCoord(latitude = 47.1195, longitude = -88.5490)
        ),
        MTUShuttleStop(
            id = "stop-rekhi",
            name = "Rekhi / Library Stop",
            routeName = "East Campus Shuttle",
            etaMinutes = 5,
            coordinate = LatLngCoord(latitude = 47.1183, longitude = -88.5462)
        ),
        MTUShuttleStop(
            id = "stop-wads",
            name = "Wadsworth Hall Stop",
            routeName = "Residential Express",
            etaMinutes = 4,
            coordinate = LatLngCoord(latitude = 47.1174, longitude = -88.5432)
        )
    )

    fun campusRouteCoordinates(to: MTUBuilding, winterMode: Boolean): List<LatLngCoord> {
        val mubHub = LatLngCoord(latitude = 47.1192, longitude = -88.5494)
        val libraryHub = LatLngCoord(latitude = 47.1187, longitude = -88.5469)
        val rekhiHub = LatLngCoord(latitude = 47.1189, longitude = -88.5458)
        val townsendMid = LatLngCoord(latitude = 47.1183, longitude = -88.5478)

        return when (to.id) {
            "mub" -> listOf(townsendMid, mubHub)
            "library" -> listOf(mubHub, libraryHub)
            "rekhi" -> if (winterMode) listOf(mubHub, libraryHub, rekhiHub) else listOf(mubHub, townsendMid, rekhiHub)
            "eerc" -> if (winterMode) listOf(mubHub, libraryHub, rekhiHub, to.coordinate) else listOf(mubHub, townsendMid, rekhiHub, to.coordinate)
            "glrc" -> {
                val overpass = LatLngCoord(latitude = 47.1197, longitude = -88.5458)
                listOf(mubHub, libraryHub, overpass, to.coordinate)
            }
            else -> listOf(mubHub, townsendMid, to.coordinate)
        }
    }

    val buildings: List<MTUBuilding> = listOf(
        // 1. Kanwal and Ann Rekhi Hall (Bldg #28)
        MTUBuilding(
            id = "rekhi",
            name = "Kanwal and Ann Rekhi Hall",
            shortName = "Rekhi Hall",
            buildingNumber = 28,
            category = MTULocationCategory.FACULTY_OFFICES,
            latitude = 47.1189,
            longitude = -88.5458,
            primaryHighlight = "CS Main Office & Advising • Rm 322",
            secondaryHighlight = "CCLC Tutoring Center (Rm 209) & Lecture Hall 214",
            openHoursText = "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 4,
            walkMinutesIndoor = 3,
            hasSkywalkAccess = true,
            skywalkRouteSummary = "MUB 2F Skywalk → Library 1F East Tunnel → Rekhi Hall West Portal (3 min heated walk)",
            phone = "906-487-2209",
            email = "cs@mtu.edu",
            officialURL = "https://www.mtu.edu/cs/",
            matchingOfficePrefixes = listOf("Rekhi"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Computing Labs, IT Dir & Associate Dean",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "rekhi-102", roomNumber = "Rm 102", title = "Stella Otoo", subtitle = "Computer Science • Rekhi Hall 102", roleBadge = "Teaching Prof", officeHours = "Mon/Wed 1:30–3:30 PM", phone = "906-487-3602", email = "sotoo@mtu.edu", rect = NormalizedRect(0.59f, 0.12f, 0.27f, 0.16f), doorwayPoint = NormalizedPoint(0.59f, 0.20f)),
                        MTUFloorRoom(id = "rekhi-103", roomNumber = "Rm 103", title = "Todd O. Arney", subtitle = "Applied Computing • Rekhi Hall 103", roleBadge = "IT Program Dir", officeHours = "Mon/Wed 1:00–3:00 PM", phone = "906-487-1085", email = "toarney@mtu.edu", rect = NormalizedRect(0.59f, 0.31f, 0.27f, 0.16f), doorwayPoint = NormalizedPoint(0.59f, 0.39f)),
                        MTUFloorRoom(id = "rekhi-104", roomNumber = "Rm 104", title = "Serein Al-Ratrout", subtitle = "Computer Science • Rekhi Hall 104", roleBadge = "Assoc Teaching Prof", officeHours = "Tue/Thu 2:00–4:00 PM", phone = "906-487-2518", email = "salratro@mtu.edu", rect = NormalizedRect(0.59f, 0.50f, 0.27f, 0.16f), doorwayPoint = NormalizedPoint(0.59f, 0.58f)),
                        MTUFloorRoom(id = "rekhi-107", roomNumber = "Rm 107", title = "Dr. Ronghua (Sam) Xu", subtitle = "Applied Computing • Rekhi Hall 107", roleBadge = "Assistant Prof", officeHours = "Tue/Thu 10:00–12:00 PM", phone = "906-487-3386", email = "ronghuax@mtu.edu", rect = NormalizedRect(0.59f, 0.69f, 0.27f, 0.16f), doorwayPoint = NormalizedPoint(0.59f, 0.77f)),
                        MTUFloorRoom(id = "rekhi-108", roomNumber = "Rm 108", title = "Tim Van Wagner", subtitle = "Applied Computing • Rekhi Hall 108", roleBadge = "Assoc Teaching Prof", officeHours = "Mon/Wed 10:00–12:00 PM", phone = "906-487-2230", email = "tavanwag@mtu.edu", rect = NormalizedRect(0.08f, 0.12f, 0.25f, 0.16f), doorwayPoint = NormalizedPoint(0.33f, 0.20f)),
                        MTUFloorRoom(id = "rekhi-110", roomNumber = "Rm 110", title = "Dr. Yu Cai", subtitle = "College of Computing • Rekhi Hall 110", roleBadge = "Associate Dean", officeHours = "Open 8:30 AM – 4:30 PM", phone = "906-487-1471", email = "cai@mtu.edu", rect = NormalizedRect(0.08f, 0.31f, 0.25f, 0.16f), doorwayPoint = NormalizedPoint(0.33f, 0.39f)),
                        MTUFloorRoom(id = "rekhi-112", roomNumber = "Rm 112", title = "Systems & Linux Lab", subtitle = "Undergraduate Computing Lab • Rekhi 112", roleBadge = "Computer Lab", officeHours = "24/7 HuskyCard Access", phone = "906-487-2209", email = "cs@mtu.edu", rect = NormalizedRect(0.08f, 0.56f, 0.25f, 0.24f), doorwayPoint = NormalizedPoint(0.33f, 0.68f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • CCLC Tutoring, Dean's Suite & CS Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "rekhi-202", roomNumber = "Rm 202", title = "Dr. Anwar Walid", subtitle = "ICC Director & CS • Rekhi Hall 202", roleBadge = "ICC Exec Dir", officeHours = "By Appointment", phone = "906-487-2514", email = "aiwalid@mtu.edu", rect = NormalizedRect(0.59f, 0.09f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.14f)),
                        MTUFloorRoom(id = "rekhi-203", roomNumber = "Rm 203", title = "Dr. Jianhui Yue", subtitle = "Computer Science • Rekhi Hall 203", roleBadge = "Associate Prof", officeHours = "Tue/Thu 1:00–3:00 PM", phone = "906-487-1726", email = "jyue@mtu.edu", rect = NormalizedRect(0.59f, 0.205f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.255f)),
                        MTUFloorRoom(id = "rekhi-204", roomNumber = "Rm 204", title = "Dr. Robert Pastel", subtitle = "HCI & Usability • Rekhi Hall 204", roleBadge = "Associate Prof", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-1639", email = "pastel@mtu.edu", rect = NormalizedRect(0.59f, 0.32f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.37f)),
                        MTUFloorRoom(id = "rekhi-205", roomNumber = "Rm 205", title = "Dr. Charles Wallace", subtitle = "Software Engineering • Rekhi Hall 205", roleBadge = "Professor", officeHours = "Tue/Thu 11:00–1:00 PM", phone = "906-487-3431", email = "wallace@mtu.edu", rect = NormalizedRect(0.59f, 0.435f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.485f)),
                        MTUFloorRoom(id = "rekhi-206", roomNumber = "Rm 206", title = "Dr. Ali Ebnenasir", subtitle = "Dependable Systems • Rekhi Hall 206", roleBadge = "Associate Prof", officeHours = "Mon/Wed 3:00–4:30 PM", phone = "906-487-4372", email = "aebnenas@mtu.edu", rect = NormalizedRect(0.59f, 0.55f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.60f)),
                        MTUFloorRoom(id = "rekhi-207", roomNumber = "Rm 207", title = "Dr. Jie Wu", subtitle = "Computer Science • Rekhi Hall 207", roleBadge = "Assistant Prof", officeHours = "Wed/Fri 1:00–3:00 PM", phone = "906-487-2320", email = "jie.jw.wu@mtu.edu", rect = NormalizedRect(0.59f, 0.665f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.715f)),
                        MTUFloorRoom(id = "rekhi-208", roomNumber = "Rm 208", title = "Dr. Keith Vertanen", subtitle = "Accessible Computing • Rekhi Hall 208", roleBadge = "Dave House Prof", officeHours = "Tue/Thu 2:00–3:30 PM", phone = "906-487-2331", email = "vertanen@mtu.edu", rect = NormalizedRect(0.59f, 0.78f, 0.27f, 0.105f), doorwayPoint = NormalizedPoint(0.59f, 0.83f)),
                        MTUFloorRoom(id = "rekhi-209", roomNumber = "Rm 209", title = "CCLC & Dr. Leo Ureel II", subtitle = "CS Learning Center • Rekhi Hall 209", roleBadge = "Learning Center", officeHours = "Open Now • Walk-in Tutoring", phone = "906-487-1816", email = "ureel@mtu.edu", rect = NormalizedRect(0.08f, 0.09f, 0.25f, 0.12f), doorwayPoint = NormalizedPoint(0.33f, 0.15f)),
                        MTUFloorRoom(id = "rekhi-210", roomNumber = "Rm 210", title = "Dr. Scott A. Kuhl", subtitle = "Graphics & VR • Rekhi Hall 210", roleBadge = "Associate Prof", officeHours = "Mon/Wed 11:00–12:30 PM", phone = "906-487-2798", email = "kuhl@mtu.edu", rect = NormalizedRect(0.08f, 0.22f, 0.25f, 0.11f), doorwayPoint = NormalizedPoint(0.33f, 0.275f)),
                        MTUFloorRoom(id = "rekhi-211", roomNumber = "Rm 211", title = "Dr. Briana Bettin", subtitle = "CS Education & UX • Rekhi Hall 211", roleBadge = "Associate Prof", officeHours = "Open until 4:00 PM", phone = "906-487-1833", email = "bcbettin@mtu.edu", rect = NormalizedRect(0.08f, 0.34f, 0.25f, 0.11f), doorwayPoint = NormalizedPoint(0.33f, 0.395f)),
                        MTUFloorRoom(id = "rekhi-212", roomNumber = "Rm 212", title = "Dr. Michael Walker", subtitle = "Human-Robot Interaction • Rekhi Hall 212", roleBadge = "Assistant Prof", officeHours = "Tue/Thu 3:00–4:30 PM", phone = "906-487-3392", email = "miwalker@mtu.edu", rect = NormalizedRect(0.08f, 0.54f, 0.25f, 0.11f), doorwayPoint = NormalizedPoint(0.33f, 0.595f)),
                        MTUFloorRoom(id = "rekhi-214", roomNumber = "Rm 214", title = "Rekhi 214 Lecture Hall", subtitle = "Main Computing Auditorium • 2nd Floor", roleBadge = "Classroom", officeHours = "Next Class: 10:13 – 11:07", phone = "906-487-2209", email = "cs@mtu.edu", rect = NormalizedRect(0.08f, 0.66f, 0.25f, 0.11f), doorwayPoint = NormalizedPoint(0.33f, 0.715f)),
                        MTUFloorRoom(id = "rekhi-221", roomNumber = "Rm 221", title = "Dr. Dennis Livesay", subtitle = "College of Computing • Rekhi Hall 221", roleBadge = "Dean of Computing", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2316", email = "dlivesay@mtu.edu", rect = NormalizedRect(0.08f, 0.78f, 0.25f, 0.11f), doorwayPoint = NormalizedPoint(0.33f, 0.835f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "3F",
                    levelTitle = "3rd Floor • CS & Applied Computing Chairs, Advising & Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "rekhi-322", roomNumber = "Rm 322", title = "CS Main Office (Wang, Landsberg, Chittick)", subtitle = "Dr. Zhenlin Wang (Chair), Denise Landsberg (Advisor), Janna Chittick", roleBadge = "CS Dept & Advising", officeHours = "Open Now • 8:00 AM – 4:30 PM", phone = "906-487-3643", email = "dllandsb@mtu.edu", rect = NormalizedRect(0.59f, 0.09f, 0.27f, 0.13f), doorwayPoint = NormalizedPoint(0.59f, 0.155f)),
                        MTUFloorRoom(id = "rekhi-323", roomNumber = "Rm 323", title = "Dr. Daniel R. Fuhrmann", subtitle = "Applied Computing Chair • Rekhi Hall 323", roleBadge = "AC Dept Chair", officeHours = "Open 8:30 AM – 4:30 PM", phone = "906-487-2871", email = "fuhrmann@mtu.edu", rect = NormalizedRect(0.59f, 0.23f, 0.27f, 0.12f), doorwayPoint = NormalizedPoint(0.59f, 0.29f)),
                        MTUFloorRoom(id = "rekhi-301", roomNumber = "Rm 301", title = "Dr. Bo Chen", subtitle = "Cybersecurity Director • Rekhi Hall 301", roleBadge = "Associate Prof", officeHours = "Wed/Fri 10:00–12:00 PM", phone = "906-487-3149", email = "bchen@mtu.edu", rect = NormalizedRect(0.59f, 0.36f, 0.27f, 0.12f), doorwayPoint = NormalizedPoint(0.59f, 0.42f)),
                        MTUFloorRoom(id = "rekhi-302", roomNumber = "Rm 302", title = "Dr. Ruihong Zhang", subtitle = "Computer Science • Rekhi Hall 302", roleBadge = "Teaching Prof", officeHours = "Mon/Wed 1:00–3:00 PM", phone = "906-487-1638", email = "ruihong@mtu.edu", rect = NormalizedRect(0.59f, 0.49f, 0.27f, 0.12f), doorwayPoint = NormalizedPoint(0.59f, 0.55f)),
                        MTUFloorRoom(id = "rekhi-303", roomNumber = "Rm 303", title = "Dr. Soner Onder", subtitle = "Computer Architecture • Rekhi Hall 303", roleBadge = "Professor", officeHours = "Tue/Thu 2:00–4:00 PM", phone = "906-487-2123", email = "soner@mtu.edu", rect = NormalizedRect(0.59f, 0.62f, 0.27f, 0.12f), doorwayPoint = NormalizedPoint(0.59f, 0.68f)),
                        MTUFloorRoom(id = "rekhi-304", roomNumber = "Rm 304", title = "Dr. Jean Mayo", subtitle = "CS Grad Program Director • Rekhi Hall 304", roleBadge = "Grad Director", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-3157", email = "jmayo@mtu.edu", rect = NormalizedRect(0.59f, 0.75f, 0.27f, 0.13f), doorwayPoint = NormalizedPoint(0.59f, 0.815f)),
                        MTUFloorRoom(id = "rekhi-307", roomNumber = "Rm 307", title = "Dr. Bo Zhang", subtitle = "Machine Learning & AI • Rekhi Hall 307", roleBadge = "Assistant Prof", officeHours = "Tue/Thu 1:30–3:30 PM", phone = "906-487-2364", email = "bo.zhang@mtu.edu", rect = NormalizedRect(0.08f, 0.10f, 0.25f, 0.14f), doorwayPoint = NormalizedPoint(0.33f, 0.17f)),
                        MTUFloorRoom(id = "rekhi-308", roomNumber = "Rm 308", title = "Dr. Gorkem Asilioglu", subtitle = "Computer Science • Rekhi Hall 308", roleBadge = "Assoc Teaching Prof", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-1643", email = "galolu@mtu.edu", rect = NormalizedRect(0.08f, 0.26f, 0.25f, 0.14f), doorwayPoint = NormalizedPoint(0.33f, 0.33f)),
                        MTUFloorRoom(id = "rekhi-309", roomNumber = "Rm 309", title = "Dr. Nilufer Onder", subtitle = "Undergrad Program Dir • Rekhi Hall 309", roleBadge = "Undergrad Dir", officeHours = "Open until 3:30 PM", phone = "906-487-1641", email = "nilufer@mtu.edu", rect = NormalizedRect(0.08f, 0.42f, 0.25f, 0.14f), doorwayPoint = NormalizedPoint(0.33f, 0.49f)),
                        MTUFloorRoom(id = "rekhi-310", roomNumber = "Rm 310", title = "Dr. Koloud Al Khamaiseh", subtitle = "Computer Science • Rekhi Hall 310", roleBadge = "Teaching Prof", officeHours = "Tue/Thu 1:00–3:00 PM", phone = "906-487-3619", email = "kalkhama@mtu.edu", rect = NormalizedRect(0.08f, 0.58f, 0.25f, 0.14f), doorwayPoint = NormalizedPoint(0.33f, 0.65f)),
                        MTUFloorRoom(id = "rekhi-311", roomNumber = "Rm 311", title = "Dr. Yakov Nekrich", subtitle = "Algorithms & Data Structures • Rekhi Hall 311", roleBadge = "Associate Prof", officeHours = "Mon/Wed 11:00–1:00 PM", phone = "906-487-2271", email = "yakov@mtu.edu", rect = NormalizedRect(0.08f, 0.74f, 0.25f, 0.14f), doorwayPoint = NormalizedPoint(0.33f, 0.81f))
                    )
                )
            )
        ),

        // 2. Administration Building (Bldg #1)
        MTUBuilding(
            id = "admin",
            name = "Administration Building",
            shortName = "Admin Building",
            buildingNumber = 1,
            category = MTULocationCategory.STUDENT_SUPPORT,
            latitude = 47.1195,
            longitude = -88.5482,
            primaryHighlight = "Waino Wahtera Center, Registrar & Dean • Rm 130",
            secondaryHighlight = "Financial Aid (103) • Career Services (220) • Grad School (414)",
            openHoursText = "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 3,
            walkMinutesIndoor = 3,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Exit MUB West Doors → 1 min cleared plaza walk across to Admin South Entrance",
            phone = "906-487-3558",
            email = "success@mtu.edu",
            officialURL = "https://www.mtu.edu/success/",
            matchingOfficePrefixes = listOf("Administration Building"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Student Success, Registrar, Financial Aid & Parking",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "admin-130", roomNumber = "Rm 130", title = "Waino Wahtera Center for Student Success", subtitle = "Academic Support, Coaching & Orientation • Admin 130", roleBadge = "Academic Support", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-3558", email = "success@mtu.edu", rect = NormalizedRect(0.59f, 0.10f, 0.27f, 0.18f), doorwayPoint = NormalizedPoint(0.59f, 0.19f)),
                        MTUFloorRoom(id = "admin-130-reg", roomNumber = "Rm 130A", title = "Registrar's Office", subtitle = "Student Affairs & Enrollment • Administration Building 130", roleBadge = "Registrar", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2319", email = "registrar@mtu.edu", rect = NormalizedRect(0.59f, 0.30f, 0.27f, 0.18f), doorwayPoint = NormalizedPoint(0.59f, 0.39f)),
                        MTUFloorRoom(id = "admin-130-dean", roomNumber = "Rm 130B", title = "Dean of Students Office", subtitle = "Student Affairs & Advocacy • Administration Building 130", roleBadge = "Dean of Students", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2212", email = "deanofstudents@mtu.edu", rect = NormalizedRect(0.59f, 0.50f, 0.27f, 0.18f), doorwayPoint = NormalizedPoint(0.59f, 0.59f)),
                        MTUFloorRoom(id = "admin-130-sds", roomNumber = "Rm 130C", title = "Student Disability Services", subtitle = "Accommodations & Testing • Administration Building 130", roleBadge = "Accessibility", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2345", email = "sds@mtu.edu", rect = NormalizedRect(0.59f, 0.70f, 0.27f, 0.18f), doorwayPoint = NormalizedPoint(0.59f, 0.79f)),
                        MTUFloorRoom(id = "admin-103", roomNumber = "Rm 103", title = "Student Financial Services & Financial Aid", subtitle = "Billing, Scholarships & Loans • Admin 103", roleBadge = "Financial Aid", officeHours = "Open Now • 8:00 AM – 4:30 PM", phone = "906-487-2622", email = "finaid@mtu.edu", rect = NormalizedRect(0.08f, 0.14f, 0.25f, 0.26f), doorwayPoint = NormalizedPoint(0.33f, 0.27f)),
                        MTUFloorRoom(id = "admin-100", roomNumber = "Rm 100", title = "Transportation & Parking Services", subtitle = "Permits, Lot Assignments & Shuttle • Admin 100", roleBadge = "Parking & Transit", officeHours = "Open 8:00 AM – 4:30 PM", phone = "906-487-1441", email = "parking@mtu.edu", rect = NormalizedRect(0.08f, 0.46f, 0.25f, 0.26f), doorwayPoint = NormalizedPoint(0.33f, 0.59f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • Career Services & International Programs",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "admin-220", roomNumber = "Rm 220", title = "Career Services", subtitle = "Career Fair Prep, Co-ops & Resume Reviews • Admin 220", roleBadge = "Career Advising", officeHours = "Open Now • Drop-in Hours", phone = "906-487-2313", email = "career@mtu.edu", rect = NormalizedRect(0.59f, 0.14f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.30f)),
                        MTUFloorRoom(id = "admin-200", roomNumber = "Rm 200", title = "International Programs and Services", subtitle = "Global Campus, Visas & Study Abroad • Admin 200", roleBadge = "International", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2160", email = "ips@mtu.edu", rect = NormalizedRect(0.59f, 0.52f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.67f)),
                        MTUFloorRoom(id = "admin-210", roomNumber = "Rm 210", title = "Employer Interview Suites", subtitle = "On-Campus Recruiting Rooms • Admin 210", roleBadge = "Interview Rooms", officeHours = "8:00 AM – 5:00 PM", phone = "906-487-2313", email = "career@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.32f), doorwayPoint = NormalizedPoint(0.33f, 0.34f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "3F",
                    levelTitle = "3rd Floor • Center for Student Mental Health & Well-being",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "admin-301", roomNumber = "Rm 301", title = "Center for Student Mental Health and Well-being", subtitle = "Counseling & Wellness Services • Admin 301", roleBadge = "Counseling", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2538", email = "counseling@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.36f), doorwayPoint = NormalizedPoint(0.59f, 0.34f)),
                        MTUFloorRoom(id = "admin-310", roomNumber = "Rm 310", title = "Mindfulness & Group Wellness Suite", subtitle = "Peer Wellness Workshops • Admin 310", roleBadge = "Wellness Lab", officeHours = "Open 9:00 AM – 4:30 PM", phone = "906-487-2538", email = "counseling@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.32f), doorwayPoint = NormalizedPoint(0.33f, 0.34f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "4F",
                    levelTitle = "4th Floor • Graduate School & Academic Leadership",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "admin-414", roomNumber = "Rm 414", title = "Graduate School Office", subtitle = "Graduate Programs, Theses & Fellowships • Admin 414", roleBadge = "Grad School", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2327", email = "gradschool@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.36f), doorwayPoint = NormalizedPoint(0.59f, 0.34f)),
                        MTUFloorRoom(id = "admin-405", roomNumber = "Rm 405", title = "Provost & Academic Affairs Suite", subtitle = "University Academic Administration • Admin 405", roleBadge = "Administration", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2440", email = "provost@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.32f), doorwayPoint = NormalizedPoint(0.33f, 0.34f))
                    )
                )
            )
        ),

        // 3. Van Pelt and Opie Library (Bldg #17)
        MTUBuilding(
            id = "library",
            name = "Van Pelt and Opie Library",
            shortName = "Van Pelt & Opie Library",
            buildingNumber = 17,
            category = MTULocationCategory.LEARNING_CENTERS,
            latitude = 47.1187,
            longitude = -88.5469,
            primaryHighlight = "IT Service Center & HuskyCard • Rm 101",
            secondaryHighlight = "Library Service Center & 24/7 Commons • 1st Floor",
            openHoursText = "Open 24 Hours • IT Desk until 6:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 3,
            walkMinutesIndoor = 2,
            hasSkywalkAccess = true,
            skywalkRouteSummary = "Direct Skywalk from MUB 2F → Library Concourse → East Tunnel to Rekhi Hall",
            phone = "906-487-2508",
            email = "library@mtu.edu",
            officialURL = "https://www.mtu.edu/library/",
            matchingOfficePrefixes = listOf("Van Pelt", "Library"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • IT Helpdesk, Service Center & Writing Center",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "lib-101", roomNumber = "Rm 101", title = "Information Technology (IT) Service Center", subtitle = "Tech Support, Wi-Fi & HuskyCard ID • Library 101", roleBadge = "IT & HuskyCard", officeHours = "Open Now • 8:00 AM – 6:00 PM", phone = "906-487-1111", email = "it-help@mtu.edu", rect = NormalizedRect(0.59f, 0.14f, 0.27f, 0.28f), doorwayPoint = NormalizedPoint(0.59f, 0.28f)),
                        MTUFloorRoom(id = "lib-svc", roomNumber = "1st Fl", title = "Van Pelt and Opie Library Service Center", subtitle = "Library Service Center, 1st Floor • Reserves & Printing", roleBadge = "Library Services", officeHours = "Open 24 Hours", phone = "906-487-2508", email = "library@mtu.edu", rect = NormalizedRect(0.59f, 0.48f, 0.27f, 0.28f), doorwayPoint = NormalizedPoint(0.59f, 0.62f)),
                        MTUFloorRoom(id = "lib-118", roomNumber = "Rm 118", title = "MTU Writing Center", subtitle = "Peer Writing & Communication Tutoring • 1st Floor West", roleBadge = "Learning Center", officeHours = "Open 10:00 AM – 8:00 PM", phone = "906-487-3251", email = "writing@mtu.edu", rect = NormalizedRect(0.08f, 0.16f, 0.25f, 0.26f), doorwayPoint = NormalizedPoint(0.33f, 0.29f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • Collaborative Study Pods & MUB Skywalk Bridge",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "lib-201", roomNumber = "Rm 201", title = "Group Study Suites (East Wing)", subtitle = "Reservable Collaboration Pods • Overlooking Husky Plaza", roleBadge = "Study Space", officeHours = "Reservable 24/7", phone = "906-487-2508", email = "library@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.31f)),
                        MTUFloorRoom(id = "lib-220", roomNumber = "Rm 220", title = "West Skywalk Concourse to MUB", subtitle = "Heated Bridge to Memorial Union Building 2F", roleBadge = "Winter Route", officeHours = "Open 24 Hours", phone = "906-487-2508", email = "library@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.28f), doorwayPoint = NormalizedPoint(0.33f, 0.32f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "3F",
                    levelTitle = "3rd Floor • Quiet Study Zone & Historical Archives",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "lib-301", roomNumber = "Rm 301", title = "Silent Reading Room", subtitle = "Portage Lake Overlook Quiet Study Zone", roleBadge = "Quiet Study", officeHours = "Open 24 Hours", phone = "906-487-2508", email = "library@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.31f)),
                        MTUFloorRoom(id = "lib-320", roomNumber = "Rm 320", title = "Copper Country Historical Archives", subtitle = "Special Collections & Reading Room • 3rd Floor West", roleBadge = "Archives", officeHours = "Mon–Fri 10:00 AM – 5:00 PM", phone = "906-487-2505", email = "copper@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.28f), doorwayPoint = NormalizedPoint(0.33f, 0.32f))
                    )
                )
            )
        ),

        // 4. Electrical Energy Resources Center (EERC • Bldg #7)
        MTUBuilding(
            id = "eerc",
            name = "Electrical Energy Resources Center",
            shortName = "EERC",
            buildingNumber = 7,
            category = MTULocationCategory.FACULTY_OFFICES,
            latitude = 47.1185,
            longitude = -88.5447,
            primaryHighlight = "ECE Dept Chair (Rm 121) & Advising (Rm 520)",
            secondaryHighlight = "The Alley Makerspace (Rm 518) & Applied Computing (4F)",
            openHoursText = "Open Now • 7:00 AM – 10:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 5,
            walkMinutesIndoor = 4,
            hasSkywalkAccess = true,
            skywalkRouteSummary = "MUB Skywalk → Library → Rekhi Hall → EERC West Indoor Walkway (4 min heated walk)",
            phone = "906-487-2550",
            email = "ece@mtu.edu",
            officialURL = "https://www.mtu.edu/ece/",
            matchingOfficePrefixes = listOf("EERC"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • ECE Department Main Office & Energy Labs",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-121", roomNumber = "Rm 121", title = "Dr. Wayne W. Weaver", subtitle = "Electrical & Computer Engineering • EERC 121", roleBadge = "ECE Dept Chair", officeHours = "Open until 4:30 PM", phone = "906-487-1461", email = "wwweaver@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f)),
                        MTUFloorRoom(id = "eerc-101", roomNumber = "Rm 101", title = "Power & Energy Systems Lab", subtitle = "High-Bay Microgrid Research Lab • EERC 101", roleBadge = "Research Lab", officeHours = "8:00 AM – 6:00 PM", phone = "906-487-2550", email = "ece@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • ECE Grad Studies, Optics & Computing Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-220", roomNumber = "Rm 220", title = "Dr. Yunlong Xing", subtitle = "Applied Computing & CS • EERC 220", roleBadge = "Assistant Prof", officeHours = "Mon/Wed 1:30–3:30 PM", phone = "906-487-2638", email = "yuxing@mtu.edu", rect = NormalizedRect(0.59f, 0.14f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.25f)),
                        MTUFloorRoom(id = "eerc-234", roomNumber = "Rm 234", title = "Dr. Aurenice M. Oliveira", subtitle = "ECE Grad Studies Director • EERC 234", roleBadge = "Associate Chair", officeHours = "Tue/Thu 1:30–3:30 PM", phone = "906-487-2494", email = "oliveira@mtu.edu", rect = NormalizedRect(0.59f, 0.40f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.51f)),
                        MTUFloorRoom(id = "eerc-236", roomNumber = "Rm 236", title = "Dr. Jeremy P. Bos", subtitle = "Autonomous Robotics & Optics • EERC 236", roleBadge = "Associate Prof", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-3161", email = "jpbos@mtu.edu", rect = NormalizedRect(0.59f, 0.66f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.77f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "4F",
                    levelTitle = "4th Floor • Applied Computing & Mechatronics Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-411", roomNumber = "Rm 411", title = "Dr. Nathir A. Rawashdeh", subtitle = "Applied Computing • EERC 411", roleBadge = "Assistant Prof", officeHours = "Tue/Thu 11:00–1:00 PM", phone = "906-487-1611", email = "narawash@mtu.edu", rect = NormalizedRect(0.59f, 0.14f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.25f)),
                        MTUFloorRoom(id = "eerc-412", roomNumber = "Rm 412", title = "Dr. Ashraf I. Saleem", subtitle = "Mechatronics Co-Director • EERC 412", roleBadge = "Assistant Prof", officeHours = "Mon/Wed 10:00–12:00 PM", phone = "906-487-2384", email = "ashraf@mtu.edu", rect = NormalizedRect(0.59f, 0.40f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.51f)),
                        MTUFloorRoom(id = "eerc-413", roomNumber = "Rm 413", title = "Dr. Aleksandr Sergeyev", subtitle = "Applied Computing Grad Dir • EERC 413", roleBadge = "Grad Program Dir", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-2258", email = "avsergue@mtu.edu", rect = NormalizedRect(0.59f, 0.66f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.77f)),
                        MTUFloorRoom(id = "eerc-417", roomNumber = "Rm 417", title = "Dr. Nader Abu-Alrub", subtitle = "Applied Computing • EERC 417", roleBadge = "Teaching Prof", officeHours = "Tue/Thu 1:00–3:00 PM", phone = "906-487-4305", email = "nabualru@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.26f), doorwayPoint = NormalizedPoint(0.33f, 0.31f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "5F",
                    levelTitle = "5th Floor • The Alley Makerspace & ECE Undergrad Advising",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-518", roomNumber = "Rm 518", title = "Dr. Shane Oberloier", subtitle = "The Alley Makerspace Director • EERC 518", roleBadge = "Makerspace Dir", officeHours = "Open Now • Prototyping Lab", phone = "906-487-2941", email = "swoberlo@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.31f)),
                        MTUFloorRoom(id = "eerc-520", roomNumber = "Rm 520", title = "Christopher (Kit) Cischke", subtitle = "ECE Undergraduate Advising • EERC 520", roleBadge = "Associate Chair", officeHours = "Open until 4:00 PM", phone = "906-487-2011", email = "cmcischk@mtu.edu", rect = NormalizedRect(0.59f, 0.50f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.65f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "6F",
                    levelTitle = "6th Floor • Microelectronics & Power Grid Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-612", roomNumber = "Rm 612", title = "Dr. Chee-Wooi Ten", subtitle = "Power Grid Cybersecurity • EERC 612", roleBadge = "Professor", officeHours = "Mon/Wed 1:00–3:00 PM", phone = "906-487-0397", email = "ten@mtu.edu", rect = NormalizedRect(0.59f, 0.14f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.25f)),
                        MTUFloorRoom(id = "eerc-629", roomNumber = "Rm 629", title = "Glen E. Archer", subtitle = "Electrical & Computer Engineering • EERC 629", roleBadge = "Teaching Prof", officeHours = "Tue/Thu 1:00–3:00 PM", phone = "906-487-2789", email = "gearcher@mtu.edu", rect = NormalizedRect(0.59f, 0.40f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.51f)),
                        MTUFloorRoom(id = "eerc-630", roomNumber = "Rm 630", title = "Dr. Paul L. Bergstrom", subtitle = "Microfabrication & MEMS • EERC 630", roleBadge = "Professor", officeHours = "Tue/Thu 10:00–12:00 PM", phone = "906-487-2058", email = "paulb@mtu.edu", rect = NormalizedRect(0.59f, 0.66f, 0.27f, 0.22f), doorwayPoint = NormalizedPoint(0.59f, 0.77f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "7F",
                    levelTitle = "7th Floor • Senior Design & Neuromorphic Computing",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "eerc-710", roomNumber = "Rm 710", title = "Dr. Hongyu An", subtitle = "Neuromorphic & VLSI Systems • EERC 710", roleBadge = "Assistant Prof", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-3382", email = "hongyua@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.31f)),
                        MTUFloorRoom(id = "eerc-731", roomNumber = "Rm 731", title = "Dr. Anthony (Tony) Pinar", subtitle = "Senior Design Coordinator • EERC 731", roleBadge = "Senior Design Dir", officeHours = "Open until 4:00 PM", phone = "906-487-0024", email = "ajpinar@mtu.edu", rect = NormalizedRect(0.59f, 0.50f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.65f))
                    )
                )
            )
        ),

        // 5. Memorial Union Building (MUB • Bldg #34)
        MTUBuilding(
            id = "mub",
            name = "Memorial Union Building (MUB)",
            shortName = "MUB",
            buildingNumber = 34,
            category = MTULocationCategory.TRANSIT_DINING,
            latitude = 47.1192,
            longitude = -88.5494,
            primaryHighlight = "Student Leadership & Involvement • Rm 112",
            secondaryHighlight = "Husky Den Food Court (2F) & Skywalk Hub",
            openHoursText = "Open Now • 7:00 AM – 11:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 2,
            walkMinutesIndoor = 1,
            hasSkywalkAccess = true,
            skywalkRouteSummary = "Central Skywalk Hub connecting directly to Van Pelt Library 2F & East Campus",
            phone = "906-487-1963",
            email = "activities@mtu.edu",
            officialURL = "https://www.mtu.edu/union/",
            matchingOfficePrefixes = listOf("Memorial Union"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Student Leadership, Bookstore & Bowling",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "mub-112", roomNumber = "Rm 112", title = "Student Leadership and Involvement", subtitle = "Student Orgs, Greek Life & Events • MUB 112", roleBadge = "Student Orgs", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-1963", email = "activities@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f)),
                        MTUFloorRoom(id = "mub-101", roomNumber = "Rm 101", title = "MTU Campus Bookstore", subtitle = "Textbooks, Tech Gear & Husky Apparel • MUB 101", roleBadge = "Campus Store", officeHours = "Open 8:30 AM – 5:00 PM", phone = "906-487-2410", email = "bookstore@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • Husky Den Food Court & Library Skywalk",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "mub-sky", roomNumber = "Skywalk", title = "MUB → Library Heated Skywalk Entrance", subtitle = "Indoor Bridge over Townsend Drive to Library 2F", roleBadge = "Winter Route", officeHours = "Open 24 Hours", phone = "906-487-1963", email = "activities@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.31f)),
                        MTUFloorRoom(id = "mub-201", roomNumber = "Rm 201", title = "Husky Den Food Court & Commons", subtitle = "Main Campus Dining & Lounge • MUB 2F", roleBadge = "Dining Hub", officeHours = "Open 7:30 AM – 9:00 PM", phone = "906-487-1963", email = "dining@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "3F",
                    levelTitle = "3rd Floor • MUB Ballroom & Conference Suites",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "mub-ballroom", roomNumber = "Rm 300", title = "MUB Ballroom", subtitle = "Career Fair, Employer Booths & Campus Banquets", roleBadge = "Event Space", officeHours = "Event Hours", phone = "906-487-1963", email = "activities@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.34f), doorwayPoint = NormalizedPoint(0.59f, 0.33f))
                    )
                )
            )
        ),

        // 6. Great Lakes Research Center (GLRC • Bldg #102)
        MTUBuilding(
            id = "glrc",
            name = "Great Lakes Research Center",
            shortName = "GLRC",
            buildingNumber = 102,
            category = MTULocationCategory.LEARNING_CENTERS,
            latitude = 47.1205,
            longitude = -88.5452,
            primaryHighlight = "GLRC Director (Dr. Timothy Havens) • Rm 307",
            secondaryHighlight = "Data Science & Sensing (Dr. Evan Lucas) • Rm 211",
            openHoursText = "Open Now • 8:00 AM – 6:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 6,
            walkMinutesIndoor = 5,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Exit Library North Door → Cross U.S. 41 Pedestrian Overpass to Portage Lake Waterfront",
            phone = "906-487-3115",
            email = "thavens@mtu.edu",
            officialURL = "https://www.mtu.edu/greatlakes/",
            matchingOfficePrefixes = listOf("GLRC"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Marine Autonomous Vessels & Waterfront Dock",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "glrc-101", roomNumber = "Rm 101", title = "Boathouse & Waterfront Lab", subtitle = "Portage Lake Research Dock • GLRC 1F", roleBadge = "Research Lab", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-3115", email = "thavens@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • Data Science & Environmental Sensing",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "glrc-211", roomNumber = "Rm 211", title = "Dr. Evan Lucas", subtitle = "Data Science & Computer Science • GLRC 211", roleBadge = "Assistant Prof", officeHours = "Mon/Wed 1:00–3:00 PM", phone = "906-487-2094", email = "eglucas@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "3F",
                    levelTitle = "3rd Floor • GLRC Executive Suite & AI Labs",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "glrc-307", roomNumber = "Rm 307", title = "Dr. Timothy C. Havens", subtitle = "GLRC Executive Director & CS Prof • GLRC 307", roleBadge = "GLRC Director", officeHours = "Open until 4:30 PM", phone = "906-487-3115", email = "thavens@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f))
                    )
                )
            )
        ),

        // 7. Academic Office Building (AOB • Bldg #5)
        MTUBuilding(
            id = "aob",
            name = "Academic Office Building (College of Business)",
            shortName = "AOB • Business",
            buildingNumber = 5,
            category = MTULocationCategory.FACULTY_OFFICES,
            latitude = 47.1198,
            longitude = -88.5508,
            primaryHighlight = "Business Advising (Ryan Neely) • Rm 108",
            secondaryHighlight = "Dean's Suite (Rm 103) & MIS / Finance Faculty (GF & 1F)",
            openHoursText = "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 4,
            walkMinutesIndoor = 4,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Walk west from Admin Building along Townsend Drive sidewalk (4 min)",
            phone = "906-487-2668",
            email = "business@mtu.edu",
            officialURL = "https://www.mtu.edu/business/",
            matchingOfficePrefixes = listOf("Academic Office Building"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "GF",
                    levelTitle = "Ground Floor • Assistant Dean, MIS Analytics & Trading Lab",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "aob-g002", roomNumber = "Rm G002", title = "Dr. Jonathan Leinonen", subtitle = "Assistant Dean & Teaching Prof • AOB G002", roleBadge = "Assistant Dean", officeHours = "Open 8:30 AM – 4:30 PM", phone = "906-487-2598", email = "jeleinon@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.28f), doorwayPoint = NormalizedPoint(0.59f, 0.30f)),
                        MTUFloorRoom(id = "aob-g010", roomNumber = "Rm G010", title = "Dr. Jeffrey Wall", subtitle = "MIS & Business Analytics • AOB G010", roleBadge = "Associate Prof", officeHours = "Mon/Wed 1:30–3:30 PM", phone = "906-487-1707", email = "jdwall@mtu.edu", rect = NormalizedRect(0.59f, 0.48f, 0.27f, 0.28f), doorwayPoint = NormalizedPoint(0.59f, 0.62f)),
                        MTUFloorRoom(id = "aob-g014", roomNumber = "Rm G014", title = "APMP Financial Trading Lab", subtitle = "Bloomberg Terminals & Portfolio Lab • AOB GF", roleBadge = "Finance Lab", officeHours = "Open 8:00 AM – 9:00 PM", phone = "906-487-2668", email = "business@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Business Dean's Suite, Advising & Faculty",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "aob-103", roomNumber = "Rm 103", title = "Dr. Sri Beldona", subtitle = "Dean of College of Business • AOB 103", roleBadge = "Business Dean", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2668", email = "sbeldona@mtu.edu", rect = NormalizedRect(0.59f, 0.10f, 0.27f, 0.17f), doorwayPoint = NormalizedPoint(0.59f, 0.185f)),
                        MTUFloorRoom(id = "aob-105", roomNumber = "Rm 105", title = "Dr. Manish K. Srivastava", subtitle = "Associate Dean & Professor • AOB 105", roleBadge = "Associate Dean", officeHours = "Open 8:30 AM – 4:30 PM", phone = "906-487-1991", email = "mksrivas@mtu.edu", rect = NormalizedRect(0.59f, 0.29f, 0.27f, 0.17f), doorwayPoint = NormalizedPoint(0.59f, 0.375f)),
                        MTUFloorRoom(id = "aob-108", roomNumber = "Rm 108", title = "Ryan Neely", subtitle = "Undergraduate Academic Advisor • AOB 108", roleBadge = "Academic Advisor", officeHours = "Open Now • Drop-in until 4:00 PM", phone = "906-487-3597", email = "rmneely@mtu.edu", rect = NormalizedRect(0.59f, 0.48f, 0.27f, 0.17f), doorwayPoint = NormalizedPoint(0.59f, 0.565f)),
                        MTUFloorRoom(id = "aob-109", roomNumber = "Rm 109", title = "Marie Cleveland", subtitle = "Student Success & Outreach • AOB 109", roleBadge = "Student Success", officeHours = "Open 8:00 AM – 4:30 PM", phone = "906-487-3055", email = "mlclevel@mtu.edu", rect = NormalizedRect(0.59f, 0.67f, 0.27f, 0.17f), doorwayPoint = NormalizedPoint(0.59f, 0.755f)),
                        MTUFloorRoom(id = "aob-114", roomNumber = "Rm 114", title = "Laura J. Sieders", subtitle = "Accounting • Academic Office Building 114", roleBadge = "Teaching Prof", officeHours = "Tue/Thu 10:00–12:00 PM", phone = "906-487-3259", email = "ljsieder@mtu.edu", rect = NormalizedRect(0.08f, 0.10f, 0.25f, 0.17f), doorwayPoint = NormalizedPoint(0.33f, 0.185f)),
                        MTUFloorRoom(id = "aob-115", roomNumber = "Rm 115", title = "Dr. Dean Johnson", subtitle = "Finance & APMP Director • AOB 115", roleBadge = "Finance Prof", officeHours = "Tue/Thu 1:00–3:00 PM", phone = "906-487-1450", email = "dean@mtu.edu", rect = NormalizedRect(0.08f, 0.29f, 0.25f, 0.17f), doorwayPoint = NormalizedPoint(0.33f, 0.375f)),
                        MTUFloorRoom(id = "aob-121", roomNumber = "Rm 121", title = "Dr. Elham Asgari", subtitle = "Management & Entrepreneurship • AOB 121", roleBadge = "Assistant Prof", officeHours = "Mon/Wed 2:00–4:00 PM", phone = "906-487-2803", email = "easgari@mtu.edu", rect = NormalizedRect(0.08f, 0.48f, 0.25f, 0.17f), doorwayPoint = NormalizedPoint(0.33f, 0.565f)),
                        MTUFloorRoom(id = "aob-123", roomNumber = "Rm 123", title = "Dr. Jenny Apriesnig", subtitle = "Economics • Academic Office Building 123", roleBadge = "Associate Prof", officeHours = "Mon/Wed 10:00–12:00 PM", phone = "906-487-2223", email = "jlapries@mtu.edu", rect = NormalizedRect(0.08f, 0.67f, 0.25f, 0.17f), doorwayPoint = NormalizedPoint(0.33f, 0.755f))
                    )
                )
            )
        ),

        // 8. Wadsworth Hall (Bldg #37)
        MTUBuilding(
            id = "wads",
            name = "Wadsworth Hall",
            shortName = "Wadsworth Hall",
            buildingNumber = 37,
            category = MTULocationCategory.TRANSIT_DINING,
            latitude = 47.1173,
            longitude = -88.5430,
            primaryHighlight = "Residence Education & Housing Services • Rm 153",
            secondaryHighlight = "Wadsworth Dining Hall & Campus Care Clinic",
            openHoursText = "Open Now • Front Desk 7:00 AM – 11:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 6,
            walkMinutesIndoor = 5,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Take East Campus Shuttle or walk east past EERC along Townsend Drive (5 min)",
            phone = "906-487-2682",
            email = "housing@mtu.edu",
            officialURL = "https://www.mtu.edu/housing/",
            matchingOfficePrefixes = listOf("Wadsworth"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Housing Services Office, Dining & Clinic",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "wads-153", roomNumber = "Rm 153", title = "Residence Education and Housing Services", subtitle = "Campus Housing, Meal Plans & Room Assignments • Wads 153", roleBadge = "Campus Housing", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2682", email = "housing@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f)),
                        MTUFloorRoom(id = "wads-110", roomNumber = "Rm 110", title = "Wadsworth Dining Hall", subtitle = "East Campus Residential Dining Commons", roleBadge = "Dining Hall", officeHours = "Open 7:00 AM – 8:00 PM", phone = "906-487-2682", email = "dining@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                )
            )
        ),

        // 9. McAllister Welcome Center (Bldg #107)
        MTUBuilding(
            id = "mcallister",
            name = "McAllister Welcome Center",
            shortName = "Welcome Center",
            buildingNumber = 107,
            category = MTULocationCategory.STUDENT_SUPPORT,
            latitude = 47.1185,
            longitude = -88.5487,
            primaryHighlight = "Undergraduate Admissions • Main Suite",
            secondaryHighlight = "Campus Tours & Prospective Student Center",
            openHoursText = "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 2,
            walkMinutesIndoor = 2,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Across Townsend Drive south of MUB & Administration Building (2 min walk)",
            phone = "906-487-2335",
            email = "admissions@mtu.edu",
            officialURL = "https://www.mtu.edu/admissions/",
            matchingOfficePrefixes = listOf("McAllister", "Welcome Center"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Undergraduate Admissions & Tour Welcome Lobby",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "mcallister-101", roomNumber = "Rm 101", title = "Undergraduate Admissions", subtitle = "McAllister Welcome Center • Admissions & Campus Visits", roleBadge = "Admissions Office", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2335", email = "admissions@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.34f), doorwayPoint = NormalizedPoint(0.59f, 0.33f)),
                        MTUFloorRoom(id = "mcallister-110", roomNumber = "Rm 110", title = "Husky Tour Presentation Hall", subtitle = "Daily Campus Tour Departure Lounge", roleBadge = "Visitor Lounge", officeHours = "Tours at 10:00 AM & 1:00 PM", phone = "906-487-2335", email = "admissions@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                )
            )
        ),

        // 10. Widmaier House (Bldg #96)
        MTUBuilding(
            id = "widmaier",
            name = "Widmaier House (Public Safety & Police)",
            shortName = "Public Safety",
            buildingNumber = 96,
            category = MTULocationCategory.STUDENT_SUPPORT,
            latitude = 47.1180,
            longitude = -88.5492,
            primaryHighlight = "Public Safety and Police Services • 206 MacInnes Dr.",
            secondaryHighlight = "24/7 Campus Dispatch, Escort Service & Lost and Found",
            openHoursText = "Open 24 Hours • 24/7 Emergency Support",
            isOpenNow = true,
            walkMinutesOutdoor = 3,
            walkMinutesIndoor = 3,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Located at 206 MacInnes Drive, just south of McAllister Welcome Center (3 min walk)",
            phone = "906-487-2216",
            email = "psps@mtu.edu",
            officialURL = "https://www.mtu.edu/publicsafety/",
            matchingOfficePrefixes = listOf("Widmaier", "MacInnes", "Public Safety"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Campus Police Headquarters & 24/7 Dispatch",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "widmaier-101", roomNumber = "Rm 101", title = "Public Safety and Police Services", subtitle = "Widmaier House, 206 MacInnes Dr. • Non-Emergency & Safety", roleBadge = "Campus Safety", officeHours = "Open 24 Hours", phone = "906-487-2216", email = "psps@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.34f), doorwayPoint = NormalizedPoint(0.59f, 0.33f))
                    )
                )
            )
        ),

        // 11. Student Development Complex (SDC • Bldg #24)
        MTUBuilding(
            id = "sdc",
            name = "Student Development Complex (SDC)",
            shortName = "SDC • Athletics",
            buildingNumber = 24,
            category = MTULocationCategory.TRANSIT_DINING,
            latitude = 47.1145,
            longitude = -88.5476,
            primaryHighlight = "Student Development Complex Main Office • Rm 100",
            secondaryHighlight = "MacInnes Ice Arena, Fitness Center & Varsity Pool",
            openHoursText = "Open Now • 6:00 AM – 10:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 8,
            walkMinutesIndoor = 7,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Walk south up MacInnes Drive past Widmaier House or ride Husky Shuttle (8 min)",
            phone = "906-487-2578",
            email = "sdc@mtu.edu",
            officialURL = "https://www.michigantechhuskies.com/",
            matchingOfficePrefixes = listOf("Student Development Complex", "SDC"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • SDC Main Office, Ice Arena & Fitness Center",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "sdc-100", roomNumber = "Rm 100", title = "Student Development Complex (SDC)", subtitle = "Athletics, Recreation & Ticket Central • SDC Main Concourse", roleBadge = "Athletics & Rec", officeHours = "Open Now • 6:00 AM – 10:00 PM", phone = "906-487-2578", email = "sdc@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.32f), doorwayPoint = NormalizedPoint(0.59f, 0.32f)),
                        MTUFloorRoom(id = "sdc-120", roomNumber = "Arena", title = "John MacInnes Student Ice Arena", subtitle = "MTU Huskies Hockey & Open Skate • SDC West Wing", roleBadge = "Ice Arena", officeHours = "Event & Rec Hours", phone = "906-487-2073", email = "sdc@mtu.edu", rect = NormalizedRect(0.08f, 0.18f, 0.25f, 0.30f), doorwayPoint = NormalizedPoint(0.33f, 0.33f))
                    )
                )
            )
        ),

        // 12. Lakeshore Center (Bldg #100)
        MTUBuilding(
            id = "lakeshore",
            name = "Lakeshore Center",
            shortName = "Lakeshore Center",
            buildingNumber = 100,
            category = MTULocationCategory.STUDENT_SUPPORT,
            latitude = 47.1214,
            longitude = -88.5562,
            primaryHighlight = "Human Resources Office • 2nd Floor (Rm 200)",
            secondaryHighlight = "Student Employment, Payroll & Sponsored Programs",
            openHoursText = "Open Now • 8:00 AM – 5:00 PM",
            isOpenNow = true,
            walkMinutesOutdoor = 9,
            walkMinutesIndoor = 8,
            hasSkywalkAccess = false,
            skywalkRouteSummary = "Take City/Husky Shuttle west along Lakeshore Drive or walk via Waterfront Trail",
            phone = "906-487-2280",
            email = "hr-help@mtu.edu",
            officialURL = "https://www.mtu.edu/hr/",
            matchingOfficePrefixes = listOf("Lakeshore Center"),
            floors = listOf(
                MTUFloorLevel(
                    levelCode = "1F",
                    levelTitle = "1st Floor • Waterfront Lobby & Enterprise Suites",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "lakeshore-100", roomNumber = "Rm 100", title = "Lakeshore Main Lobby & Innovation Hub", subtitle = "Waterfront Atrium • Lakeshore Center 1F", roleBadge = "Atrium Hub", officeHours = "Open 8:00 AM – 5:00 PM", phone = "906-487-2280", email = "hr-help@mtu.edu", rect = NormalizedRect(0.59f, 0.18f, 0.27f, 0.30f), doorwayPoint = NormalizedPoint(0.59f, 0.33f))
                    )
                ),
                MTUFloorLevel(
                    levelCode = "2F",
                    levelTitle = "2nd Floor • Human Resources, Payroll & Student Employment",
                    elevatorPoint = NormalizedPoint(0.45f, 0.78f),
                    hallwaySpineX = 0.56f,
                    rooms = listOf(
                        MTUFloorRoom(id = "lakeshore-200", roomNumber = "2nd Fl", title = "Human Resources Office", subtitle = "Lakeshore Center, 2nd Floor • Student Jobs, I-9 & Benefits", roleBadge = "Human Resources", officeHours = "Open Now • 8:00 AM – 5:00 PM", phone = "906-487-2280", email = "hr-help@mtu.edu", rect = NormalizedRect(0.59f, 0.16f, 0.27f, 0.34f), doorwayPoint = NormalizedPoint(0.59f, 0.33f))
                    )
                )
            )
        )
    )

    fun matchBuilding(contact: Contact): BuildingRoomMatch? {
        val office = contact.office ?: return null
        for (building in buildings) {
            if (building.matchingOfficePrefixes.any { office.contains(it, ignoreCase = true) }) {
                // 1. Try matching by exact person/office name or email first
                for (floor in building.floors) {
                    val nameOrEmailMatch = floor.rooms.firstOrNull { room ->
                        room.email.equals(contact.email, ignoreCase = true) ||
                            room.title.contains(contact.name, ignoreCase = true) ||
                            contact.name.contains(room.title, ignoreCase = true) ||
                            room.subtitle.contains(contact.name, ignoreCase = true)
                    }
                    if (nameOrEmailMatch != null) {
                        return BuildingRoomMatch(building, floor.levelCode, nameOrEmailMatch)
                    }
                }
                // 2. Match by exact room token
                for (floor in building.floors) {
                    val roomMatch = floor.rooms.firstOrNull { room ->
                        val cleanNum = room.roomNumber.replace("Rm ", "").trim()
                        office.contains(cleanNum, ignoreCase = true)
                    }
                    if (roomMatch != null) {
                        return BuildingRoomMatch(building, floor.levelCode, roomMatch)
                    }
                }
                // 3. Infer floor code from 3-digit room number if present
                val digits = office.split(Regex("[^0-9]+")).firstOrNull { it.length == 3 }
                if (digits != null) {
                    val floorCode = "${digits.first()}F"
                    val floor = building.floors.firstOrNull { it.levelCode == floorCode }
                    if (floor != null) {
                        return BuildingRoomMatch(building, floor.levelCode, floor.rooms.firstOrNull())
                    }
                }
                val fallbackFloor = building.floors.firstOrNull()
                return BuildingRoomMatch(building, fallbackFloor?.levelCode, fallbackFloor?.rooms?.firstOrNull())
            }
        }
        return null
    }
}
