package com.locistoa.app.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsWalk
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.filled.AcUnit
import androidx.compose.material.icons.filled.Apartment
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.MeetingRoom
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Route
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Stairs
import androidx.compose.material.icons.filled.SwapVert
import androidx.compose.material.icons.filled.WaterDrop
import androidx.compose.material.icons.filled.Wc
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.locistoa.app.data.Contact
import com.locistoa.app.data.MTUBuilding
import com.locistoa.app.data.MTUCampusData
import com.locistoa.app.data.MTUFloorLandmarkKind
import com.locistoa.app.data.MTUFloorRoom
import com.locistoa.app.data.MTURoomKind
import com.locistoa.app.ui.theme.LociBrandState
import kotlin.math.max
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MTUIndoorMapScreen(
    building: MTUBuilding,
    initialFloorCode: String? = null,
    initialRoom: MTUFloorRoom? = null,
    directoryContacts: List<Contact> = emptyList(),
    onBackToCampusMap: (() -> Unit)? = null,
    onClose: () -> Unit
) {
    val context = LocalContext.current
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    var selectedFloorCode by remember(building.id, initialFloorCode) {
        mutableStateOf(initialFloorCode ?: building.floors.lastOrNull()?.levelCode ?: "1F")
    }

    val currentFloor = remember(building, selectedFloorCode) {
        building.floors.firstOrNull { it.levelCode == selectedFloorCode } ?: building.floors.first()
    }

    var selectedRoom by remember(building.id, initialRoom) {
        mutableStateOf(initialRoom ?: currentFloor.rooms.firstOrNull())
    }

    val availablePortals = remember(building, currentFloor) {
        currentFloor.entryPortals(building)
    }

    var selectedPortalID by remember(building.id, currentFloor.levelCode) {
        mutableStateOf(availablePortals.firstOrNull()?.id ?: "elevator")
    }

    val activePortal = remember(availablePortals, selectedPortalID) {
        availablePortals.firstOrNull { it.id == selectedPortalID } ?: availablePortals.first()
    }

    var showAnimatedPath by remember { mutableStateOf(true) }
    var showTurnByTurnSteps by remember { mutableStateOf(false) }

    LaunchedEffect(building.id, initialFloorCode, initialRoom) {
        val startFloor = initialFloorCode ?: building.floors.lastOrNull()?.levelCode ?: "1F"
        selectedFloorCode = startFloor
        val floorObj = building.floors.firstOrNull { it.levelCode == startFloor } ?: building.floors.first()
        selectedRoom = initialRoom ?: floorObj.rooms.firstOrNull()
    }

    val floorContacts = remember(directoryContacts, building, selectedFloorCode) {
        directoryContacts.filter { contact ->
            val office = contact.office ?: return@filter false
            val matchesBuilding = building.matchingOfficePrefixes.any { office.contains(it, ignoreCase = true) }
            if (!matchesBuilding) return@filter false
            if (selectedFloorCode == "GF") {
                return@filter office.contains("G0", ignoreCase = true)
            }
            val floorDigit = selectedFloorCode.take(1)
            val roomNumbers = office.split(Regex("[^0-9]+")).filter { it.isNotEmpty() }
            val num = roomNumbers.firstOrNull()
            if (num != null) {
                num.startsWith(floorDigit)
            } else {
                selectedFloorCode == "1F"
            }
        }
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "${building.shortName} • Bldg #${building.buildingNumber}",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                },
                navigationIcon = {
                    if (onBackToCampusMap != null) {
                        TextButton(onClick = onBackToCampusMap) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowLeft,
                                    contentDescription = null,
                                    tint = lociAccent
                                )
                                Text(
                                    text = "Campus Map",
                                    color = lociAccent,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                },
                actions = {
                    TextButton(onClick = onClose) {
                        Text(
                            text = "Close",
                            color = lociAccent,
                            fontWeight = FontWeight.Bold
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            // 1. Header & Route Entry Portal Selector
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Apartment,
                        contentDescription = null,
                        tint = lociAccent,
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = currentFloor.levelTitle,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = lociAccent,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    selectedRoom?.let { room ->
                        val summary = currentFloor.routeSummary(activePortal, room)
                        Surface(
                            shape = CircleShape,
                            color = Color.White.copy(alpha = 0.9f)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(3.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.DirectionsWalk,
                                    contentDescription = null,
                                    tint = lociAccent,
                                    modifier = Modifier.size(12.dp)
                                )
                                Text(
                                    text = "${summary.distanceFeet} ft • ~${summary.seconds}s",
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = lociAccent
                                )
                            }
                        }
                    }
                    Surface(
                        onClick = { showAnimatedPath = !showAnimatedPath },
                        shape = CircleShape,
                        color = if (showAnimatedPath) lociAccent else Color.White
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 9.dp, vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Route,
                                contentDescription = null,
                                tint = if (showAnimatedPath) Color.White else lociAccent,
                                modifier = Modifier.size(12.dp)
                            )
                            Text(
                                text = if (showAnimatedPath) "Route On" else "Route Off",
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (showAnimatedPath) Color.White else lociAccent
                            )
                        }
                    }
                }

                // Route From selector + Room Category Legend
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState())
                        .padding(horizontal = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(
                        text = "Route From:",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.DarkGray
                    )

                    availablePortals.forEach { portal ->
                        val isSelected = (activePortal.id == portal.id)
                        Surface(
                            onClick = {
                                selectedPortalID = portal.id
                                showAnimatedPath = true
                            },
                            shape = CircleShape,
                            color = if (isSelected) lociAccent else Color.White.copy(alpha = 0.85f)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 9.dp, vertical = 4.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(
                                    text = portal.shortLabel,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (isSelected) Color.White else Color(0xFF1A1A2E)
                                )
                            }
                        }
                    }

                    listOf(
                        MTURoomKind.DEPARTMENT_HUB,
                        MTURoomKind.FACULTY_OFFICE,
                        MTURoomKind.LEARNING_LAB,
                        MTURoomKind.STUDENT_SUPPORT
                    ).forEach { kind ->
                        Surface(
                            shape = CircleShape,
                            color = Color.White.copy(alpha = 0.65f)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(7.dp)
                                        .clip(CircleShape)
                                        .background(kind.color)
                                )
                                Text(
                                    text = kind.rawValue,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = Color.DarkGray
                                )
                            }
                        }
                    }
                }
            }

            // 2. Interactive Architectural Floor Plan Canvas + Floor Switcher
            BoxWithConstraints(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                val density = LocalDensity.current
                val wPx = constraints.maxWidth.toFloat()
                val hPx = constraints.maxHeight.toFloat()
                val wDp = maxWidth
                val hDp = maxHeight

                val infiniteTransition = rememberInfiniteTransition(label = "IndoorPathDash")
                val dashPhase by infiniteTransition.animateFloat(
                    initialValue = 0f,
                    targetValue = -56f,
                    animationSpec = infiniteRepeatable(
                        animation = tween(durationMillis = 1200, easing = LinearEasing),
                        repeatMode = RepeatMode.Restart
                    ),
                    label = "DashPhase"
                )

                // A. Architectural Blueprint Canvas (Shell, Wings, Corridors, Doorways & Animated Walking Path)
                Canvas(modifier = Modifier.fillMaxSize()) {
                    // Outer Architectural Building Footprint Shell (centered at 0.46w, 0.50h, size 0.84w x 0.88h)
                    val shellW = wPx * 0.84f
                    val shellH = hPx * 0.88f
                    val shellLeft = wPx * 0.46f - shellW / 2f
                    val shellTop = hPx * 0.50f - shellH / 2f

                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.65f),
                        topLeft = Offset(shellLeft, shellTop),
                        size = Size(shellW, shellH),
                        cornerRadius = CornerRadius(18.dp.toPx(), 18.dp.toPx())
                    )
                    drawRoundRect(
                        color = Color(0xFF1A1A2E).copy(alpha = 0.30f),
                        topLeft = Offset(shellLeft, shellTop),
                        size = Size(shellW, shellH),
                        cornerRadius = CornerRadius(18.dp.toPx(), 18.dp.toPx()),
                        style = Stroke(width = 2.dp.toPx())
                    )

                    // West Wing Background
                    val westW = wPx * 0.26f
                    val westH = hPx * 0.82f
                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.48f),
                        topLeft = Offset(wPx * 0.205f - westW / 2f, hPx * 0.50f - westH / 2f),
                        size = Size(westW, westH),
                        cornerRadius = CornerRadius(12.dp.toPx(), 12.dp.toPx())
                    )

                    // East Wing Background
                    val eastW = wPx * 0.28f
                    val eastH = hPx * 0.82f
                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.48f),
                        topLeft = Offset(wPx * 0.725f - eastW / 2f, hPx * 0.50f - eastH / 2f),
                        size = Size(eastW, eastH),
                        cornerRadius = CornerRadius(12.dp.toPx(), 12.dp.toPx())
                    )

                    // Multi-Corridor Hallway Network
                    val corridorColor = lociBackground.copy(alpha = 0.78f)

                    // 1) West North-South Corridor
                    val westCorrW = wPx * 0.048f
                    val corrH = hPx * 0.80f
                    drawRoundRect(
                        color = corridorColor,
                        topLeft = Offset(wPx * currentFloor.westHallwaySpineX - westCorrW / 2f, hPx * 0.50f - corrH / 2f),
                        size = Size(westCorrW, corrH),
                        cornerRadius = CornerRadius(6.dp.toPx(), 6.dp.toPx())
                    )

                    // 2) East North-South Main Corridor
                    val eastCorrW = wPx * 0.052f
                    drawRoundRect(
                        color = corridorColor,
                        topLeft = Offset(wPx * currentFloor.hallwaySpineX - eastCorrW / 2f, hPx * 0.50f - corrH / 2f),
                        size = Size(eastCorrW, corrH),
                        cornerRadius = CornerRadius(6.dp.toPx(), 6.dp.toPx())
                    )

                    // 3) North Cross-Corridor
                    val crossW = wPx * 0.24f
                    val northCrossH = hPx * 0.045f
                    drawRoundRect(
                        color = corridorColor,
                        topLeft = Offset(wPx * 0.46f - crossW / 2f, hPx * currentFloor.northCrossHallY - northCrossH / 2f),
                        size = Size(crossW, northCrossH),
                        cornerRadius = CornerRadius(6.dp.toPx(), 6.dp.toPx())
                    )

                    // 4) South Lobby Cross-Corridor
                    val southCrossH = hPx * 0.055f
                    drawRoundRect(
                        color = corridorColor,
                        topLeft = Offset(wPx * 0.46f - crossW / 2f, hPx * currentFloor.southCrossHallY - southCrossH / 2f),
                        size = Size(crossW, southCrossH),
                        cornerRadius = CornerRadius(6.dp.toPx(), 6.dp.toPx())
                    )

                    // Skywalk Connector Corridor
                    if (building.hasSkywalkAccess && (currentFloor.levelCode == "1F" || currentFloor.levelCode == "2F")) {
                        val skyW = wPx * 0.28f
                        val skyH = hPx * 0.045f
                        val skyTopLeft = Offset(wPx * 0.22f - skyW / 2f, hPx * 0.50f - skyH / 2f)
                        drawRoundRect(
                            color = Color(0xFF2196F3).copy(alpha = 0.14f),
                            topLeft = skyTopLeft,
                            size = Size(skyW, skyH),
                            cornerRadius = CornerRadius(4.dp.toPx(), 4.dp.toPx())
                        )
                    }

                    // Doorway Threshold Markers on Corridor Edge
                    currentFloor.rooms.forEach { room ->
                        val isSel = (selectedRoom?.id == room.id)
                        drawCircle(
                            color = if (isSel) lociAccent else room.kind.color.copy(alpha = 0.65f),
                            radius = (if (isSel) 4.dp else 2.5.dp).toPx(),
                            center = Offset(wPx * room.doorwayPoint.x, hPx * room.doorwayPoint.y)
                        )
                    }

                    // C. Glowing Multi-Segment Walking Path from Selected Portal to Room Doorway
                    val targetRoom = selectedRoom
                    if (showAnimatedPath && targetRoom != null) {
                        val waypoints = currentFloor.routeWaypoints(activePortal, targetRoom)
                        if (waypoints.size >= 2) {
                            val path = Path().apply {
                                moveTo(wPx * waypoints.first().x, hPx * waypoints.first().y)
                                waypoints.drop(1).forEach { pt ->
                                    lineTo(wPx * pt.x, hPx * pt.y)
                                }
                            }

                            // Outer Glow Path
                            drawPath(
                                path = path,
                                color = lociAccent.copy(alpha = 0.28f),
                                style = Stroke(
                                    width = 9.dp.toPx(),
                                    cap = StrokeCap.Round,
                                    join = StrokeJoin.Round
                                )
                            )

                            // Animated Dashed Core Path
                            drawPath(
                                path = path,
                                color = lociAccent,
                                style = Stroke(
                                    width = 4.dp.toPx(),
                                    cap = StrokeCap.Round,
                                    join = StrokeJoin.Round,
                                    pathEffect = PathEffect.dashPathEffect(
                                        intervals = floatArrayOf(16f, 18f),
                                        phase = dashPhase
                                    )
                                )
                            )

                            // Origin Marker Badge ("START")
                            val startOffset = Offset(wPx * waypoints.first().x, hPx * waypoints.first().y)
                            drawCircle(
                                color = Color.White,
                                radius = 6.dp.toPx(),
                                center = startOffset
                            )
                            drawCircle(
                                color = Color(0xFF2E7D32),
                                radius = 4.5.dp.toPx(),
                                center = startOffset
                            )

                            // Destination Doorway Pin
                            val endOffset = Offset(wPx * waypoints.last().x, hPx * waypoints.last().y)
                            drawCircle(
                                color = Color.White,
                                radius = 7.dp.toPx(),
                                center = endOffset
                            )
                            drawCircle(
                                color = lociAccent,
                                radius = 5.5.dp.toPx(),
                                center = endOffset
                            )
                        }
                    }
                }

                // Wing Header Labels
                Text(
                    text = "WEST WING",
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.DarkGray.copy(alpha = 0.7f),
                    modifier = Modifier.offset(x = wDp * 0.14f, y = hDp * 0.065f)
                )
                Text(
                    text = "CENTRAL CORE",
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.DarkGray.copy(alpha = 0.7f),
                    modifier = Modifier.offset(x = wDp * 0.39f, y = hDp * 0.065f)
                )
                Text(
                    text = "EAST WING",
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.DarkGray.copy(alpha = 0.7f),
                    modifier = Modifier.offset(x = wDp * 0.66f, y = hDp * 0.065f)
                )

                // NORTH Reference Banner
                Surface(
                    shape = CircleShape,
                    color = Color.White.copy(alpha = 0.92f),
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .padding(top = 2.dp, end = 30.dp)
                ) {
                    Text(
                        text = "▲ NORTH: ${building.northReference}",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1A1A2E),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 2.dp)
                    )
                }

                // SOUTH Reference Banner
                Surface(
                    shape = CircleShape,
                    color = Color.White.copy(alpha = 0.92f),
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(bottom = 2.dp, end = 30.dp)
                ) {
                    Text(
                        text = "▼ SOUTH: ${building.southReference}",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1A1A2E),
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 2.dp)
                    )
                }

                // Compass Rose Badge (Top-Left)
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = Color.White.copy(alpha = 0.92f),
                    shadowElevation = 2.dp,
                    modifier = Modifier
                        .padding(start = 10.dp, top = 4.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("N", fontSize = 8.sp, fontWeight = FontWeight.Black, color = lociAccent)
                        Text("W•E", fontSize = 6.sp, fontWeight = FontWeight.Bold, color = Color.Gray)
                    }
                }

                // Scale Bar (Bottom-Left)
                Surface(
                    shape = RoundedCornerShape(4.dp),
                    color = Color.White.copy(alpha = 0.88f),
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .padding(start = 10.dp, bottom = 4.dp)
                ) {
                    Text(
                        text = "|— 50 ft —|",
                        fontSize = 7.sp,
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        color = Color.DarkGray,
                        modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                    )
                }

                // Central Service Core Landmarks
                currentFloor.landmarks(building).forEach { landmark ->
                    val isPortalOrigin = (activePortal.point == landmark.point)
                    val lmWidthDp = wDp * 0.12f
                    val lmHeightDp = 28.dp
                    val xOff = wDp * landmark.point.x - lmWidthDp / 2
                    val yOff = hDp * landmark.point.y - lmHeightDp / 2

                    Surface(
                        shape = RoundedCornerShape(7.dp),
                        color = if (isPortalOrigin) lociAccent else Color.White.copy(alpha = 0.95f),
                        shadowElevation = 2.dp,
                        modifier = Modifier
                            .offset(x = xOff, y = yOff)
                            .widthIn(min = lmWidthDp)
                            .border(
                                width = if (isPortalOrigin) 1.5.dp else 1.dp,
                                color = if (isPortalOrigin) lociAccent else landmark.kind.tint.copy(alpha = 0.45f),
                                shape = RoundedCornerShape(7.dp)
                            )
                    ) {
                        Column(
                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = when (landmark.kind) {
                                    MTUFloorLandmarkKind.ELEVATOR -> Icons.Default.SwapVert
                                    MTUFloorLandmarkKind.STAIRS -> Icons.Default.Stairs
                                    MTUFloorLandmarkKind.RESTROOM -> Icons.Default.Wc
                                    MTUFloorLandmarkKind.WATER -> Icons.Default.WaterDrop
                                    MTUFloorLandmarkKind.SKYWALK -> Icons.Default.AcUnit
                                    MTUFloorLandmarkKind.ENTRANCE -> Icons.Default.MeetingRoom
                                    MTUFloorLandmarkKind.LOUNGE -> Icons.Default.Apartment
                                },
                                contentDescription = null,
                                tint = if (isPortalOrigin) Color.White else landmark.kind.tint,
                                modifier = Modifier.size(11.dp)
                            )
                            Text(
                                text = landmark.title,
                                fontSize = 7.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isPortalOrigin) Color.White else Color(0xFF1A1A2E),
                                maxLines = 1
                            )
                        }
                    }
                }

                // B. Interactive Rooms on Current Floor
                currentFloor.rooms.forEach { room ->
                    val isSelected = (selectedRoom?.id == room.id)
                    val roomW = wDp * room.rect.width
                    val roomH = hDp * room.rect.height
                    val leftX = wDp * room.rect.x
                    val topY = hDp * room.rect.y
                    val isCompact = (roomH < 42.dp)
                    val kindColor = room.kind.color
                    val cornerShape = RoundedCornerShape(if (isCompact) 7.dp else 10.dp)

                    Surface(
                        onClick = {
                            selectedRoom = room
                            showAnimatedPath = true
                        },
                        shape = cornerShape,
                        color = if (isSelected) Color(0xFFEDE4FF) else Color.White.copy(alpha = 0.96f),
                        shadowElevation = if (isSelected) 5.dp else 1.dp,
                        modifier = Modifier
                            .offset(x = leftX, y = topY)
                            .size(width = roomW, height = roomH)
                            .border(
                                width = if (isSelected) 2.2.dp else 1.1.dp,
                                color = if (isSelected) lociAccent else kindColor.copy(alpha = 0.55f),
                                shape = cornerShape
                            )
                    ) {
                        Row(
                            modifier = Modifier.fillMaxSize(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Left color accent bar
                            Box(
                                modifier = Modifier
                                    .padding(start = 3.dp, top = 3.dp, bottom = 3.dp)
                                    .width(3.5.dp)
                                    .fillMaxHeight()
                                    .clip(RoundedCornerShape(3.dp))
                                    .background(if (isSelected) lociAccent else kindColor)
                            )

                            if (isCompact) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 5.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Text(
                                        text = room.roomNumber.replace("Rm ", ""),
                                        fontSize = 9.5.sp,
                                        fontWeight = FontWeight.Black,
                                        color = if (isSelected) lociAccent else kindColor,
                                        maxLines = 1
                                    )
                                    Text(
                                        text = room.title,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = Color(0xFF1A1A2E),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                            } else {
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 5.dp, vertical = 2.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.Center
                                ) {
                                    Text(
                                        text = room.roomNumber,
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Black,
                                        color = if (isSelected) lociAccent else Color(0xFF1A1A2E),
                                        maxLines = 1
                                    )
                                    Text(
                                        text = room.title,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = Color(0xFF1A1A2E).copy(alpha = 0.9f),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    if (roomH > 58.dp) {
                                        Text(
                                            text = room.roleBadge,
                                            fontSize = 7.5.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = kindColor,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // D. Selected Room Floating Callout Pill
                selectedRoom?.let { room ->
                    val calloutX = (wDp * room.rect.midX - 55.dp).coerceIn(8.dp, wDp - 130.dp)
                    val calloutY = (hDp * room.rect.y - 22.dp).coerceAtLeast(18.dp)
                    Surface(
                        shape = CircleShape,
                        color = Color.White,
                        shadowElevation = 4.dp,
                        modifier = Modifier
                            .offset(x = calloutX, y = calloutY)
                            .border(1.dp, lociAccent.copy(alpha = 0.5f), CircleShape)
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(3.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.LocationOn,
                                contentDescription = null,
                                tint = lociAccent,
                                modifier = Modifier.size(10.dp)
                            )
                            Text(
                                text = "${room.roomNumber} • ${room.wingName}",
                                fontSize = 9.5.sp,
                                fontWeight = FontWeight.Black,
                                color = Color(0xFF1A1A2E)
                            )
                        }
                    }
                }

                // Vertical Floor Switcher Pill on Right Side
                val isManyFloors = building.floors.size > 4
                val btnSize = if (isManyFloors) 34.dp else 40.dp
                Surface(
                    shape = CircleShape,
                    color = Color.White.copy(alpha = 0.90f),
                    shadowElevation = 6.dp,
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(end = 10.dp, bottom = 12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(6.dp),
                        verticalArrangement = Arrangement.spacedBy(if (isManyFloors) 5.dp else 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        building.floors.reversed().forEach { floor ->
                            val isSel = (floor.levelCode == selectedFloorCode)
                            Box(
                                modifier = Modifier
                                    .size(btnSize)
                                    .clip(CircleShape)
                                    .background(if (isSel) lociAccent else Color.White)
                                    .clickable {
                                        selectedFloorCode = floor.levelCode
                                        selectedRoom = floor.rooms.firstOrNull()
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = floor.levelCode,
                                    fontSize = if (isManyFloors) 11.sp else 13.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (isSel) Color.White else Color(0xFF1A1A2E)
                                )
                            }
                        }
                    }
                }
            }

            // 3. Horizontal Floor-Wide Room Quick-Jump Strip
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 14.dp),
                horizontalArrangement = Arrangement.spacedBy(7.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                currentFloor.rooms.forEach { room ->
                    val isSelected = (selectedRoom?.id == room.id)
                    Surface(
                        onClick = {
                            selectedRoom = room
                            showAnimatedPath = true
                        },
                        shape = CircleShape,
                        color = if (isSelected) lociAccent else Color.White.copy(alpha = 0.92f),
                        modifier = Modifier.border(
                            width = 1.dp,
                            color = if (isSelected) Color.Transparent else room.kind.color.copy(alpha = 0.35f),
                            shape = CircleShape
                        )
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(5.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(7.dp)
                                    .clip(CircleShape)
                                    .background(if (isSelected) Color.White else room.kind.color)
                            )
                            Text(
                                text = "${room.roomNumber} • ${room.title}",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.White else Color(0xFF1A1A2E),
                                maxLines = 1
                            )
                        }
                    }
                }
            }

            // 4. Bottom Room Inspector Card
            selectedRoom?.let { room ->
                val routeInfo = currentFloor.routeSummary(activePortal, room)
                Surface(
                    shape = RoundedCornerShape(22.dp),
                    color = Color.White,
                    shadowElevation = 6.dp,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 14.dp)
                        .padding(bottom = 8.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = "${room.roomNumber} • ${room.title}",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 15.sp,
                                    color = Color(0xFF1A1A2E),
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Text(
                                    text = room.subtitle,
                                    fontSize = 12.sp,
                                    color = lociAccent,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                            Surface(
                                shape = CircleShape,
                                color = room.kind.color
                            ) {
                                Text(
                                    text = room.roleBadge,
                                    color = Color.White,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                                )
                            }
                        }

                        // Spatial Reference & Office Hours Row
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                shape = CircleShape,
                                color = lociBackground.copy(alpha = 0.45f),
                                modifier = Modifier.weight(1f, fill = false)
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 9.dp, vertical = 5.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Explore,
                                        contentDescription = null,
                                        tint = lociAccent,
                                        modifier = Modifier.size(12.dp)
                                    )
                                    Text(
                                        text = room.relativeReferenceText,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = Color(0xFF1A1A2E),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.width(6.dp))

                            Surface(
                                shape = CircleShape,
                                color = Color.LightGray.copy(alpha = 0.25f)
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 9.dp, vertical = 5.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Schedule,
                                        contentDescription = null,
                                        tint = Color(0xFF2E7D32),
                                        modifier = Modifier.size(12.dp)
                                    )
                                    Text(
                                        text = room.officeHours,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = Color(0xFF1A1A2E),
                                        maxLines = 1
                                    )
                                }
                            }
                        }

                        // Expandable Turn-by-Turn Indoor Navigation Steps
                        AnimatedVisibility(visible = showTurnByTurnSteps) {
                            Surface(
                                shape = RoundedCornerShape(12.dp),
                                color = lociBackground.copy(alpha = 0.35f),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Column(
                                    modifier = Modifier.padding(9.dp),
                                    verticalArrangement = Arrangement.spacedBy(5.dp)
                                ) {
                                    routeInfo.steps.forEachIndexed { idx, step ->
                                        Row(
                                            verticalAlignment = Alignment.Top,
                                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            Box(
                                                modifier = Modifier
                                                    .size(16.dp)
                                                    .clip(CircleShape)
                                                    .background(lociAccent),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Text(
                                                    text = "${idx + 1}",
                                                    fontSize = 9.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    color = Color.White
                                                )
                                            }
                                            Text(
                                                text = step,
                                                fontSize = 11.sp,
                                                fontWeight = FontWeight.Medium,
                                                color = Color(0xFF1A1A2E)
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        // Additional Directory Contacts on this Floor
                        if (floorContacts.isNotEmpty()) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .horizontalScroll(rememberScrollState()),
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                floorContacts.forEach { person ->
                                    Surface(
                                        onClick = {
                                            MTUCampusData.matchBuilding(person)?.room?.let { matchedRoom ->
                                                selectedRoom = matchedRoom
                                                showAnimatedPath = true
                                            }
                                        },
                                        shape = CircleShape,
                                        color = lociBackground.copy(alpha = 0.4f)
                                    ) {
                                        Row(
                                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                                        ) {
                                            Icon(
                                                imageVector = Icons.Default.Person,
                                                contentDescription = null,
                                                tint = lociAccent,
                                                modifier = Modifier.size(12.dp)
                                            )
                                            val shortOffice = (person.office ?: "")
                                                .replace("${building.name} ", "")
                                                .replace("${building.shortName} ", "")
                                            Text(
                                                text = "${person.name} ($shortOffice)",
                                                fontSize = 10.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = Color(0xFF1A1A2E)
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        // Action Buttons (Turn-by-Turn Steps, Phone, Email)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                onClick = {
                                    showAnimatedPath = true
                                    showTurnByTurnSteps = !showTurnByTurnSteps
                                },
                                shape = RoundedCornerShape(11.dp),
                                color = lociAccent,
                                modifier = Modifier.weight(1f)
                            ) {
                                Row(
                                    modifier = Modifier.padding(vertical = 10.dp, horizontal = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Route,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(
                                        text = if (showTurnByTurnSteps) "Hide Steps (${routeInfo.distanceFeet} ft)" else "Indoor Steps (${routeInfo.distanceFeet} ft)",
                                        fontSize = 11.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.White
                                    )
                                }
                            }

                            Surface(
                                onClick = {
                                    try {
                                        context.startActivity(
                                            Intent(Intent.ACTION_DIAL, Uri.parse("tel:${room.phone}"))
                                        )
                                    } catch (_: Exception) {
                                    }
                                },
                                shape = RoundedCornerShape(11.dp),
                                color = lociAccent.copy(alpha = 0.15f)
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 11.dp, vertical = 10.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Phone,
                                        contentDescription = "Call",
                                        tint = lociAccent,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Text(
                                        text = room.phone,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }
                            }

                            Surface(
                                onClick = {
                                    try {
                                        context.startActivity(
                                            Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:${room.email}"))
                                        )
                                    } catch (_: Exception) {
                                    }
                                },
                                shape = RoundedCornerShape(11.dp),
                                color = lociAccent.copy(alpha = 0.15f)
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 11.dp, vertical = 10.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Email,
                                        contentDescription = "Email",
                                        tint = lociAccent,
                                        modifier = Modifier.size(14.dp)
                                    )
                                    Text(
                                        text = "Email",
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
