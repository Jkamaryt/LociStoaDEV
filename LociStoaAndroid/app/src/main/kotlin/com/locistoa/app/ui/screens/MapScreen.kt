package com.locistoa.app.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AcUnit
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Apartment
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.DirectionsBus
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.NearMe
import androidx.compose.material.icons.filled.NorthEast
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.locistoa.app.data.Contact
import com.locistoa.app.data.ContactRepository
import com.locistoa.app.data.LatLngCoord
import com.locistoa.app.data.MTUBuilding
import com.locistoa.app.data.MTUCampusData
import com.locistoa.app.data.MTUFloorRoom
import com.locistoa.app.data.MTULocationCategory
import com.locistoa.app.ui.theme.LociBrandState

data class OfficeSearchMatch(
    val building: MTUBuilding,
    val floorCode: String,
    val room: MTUFloorRoom
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    focusedContact: Contact? = null,
    onClose: () -> Unit
) {
    val context = LocalContext.current
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    val initialMatch = remember(focusedContact) {
        focusedContact?.let { MTUCampusData.matchBuilding(it) }
    }

    var contacts by remember { mutableStateOf(ContactRepository.fallbackContacts) }
    var searchText by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(MTULocationCategory.ALL) }

    var selectedBuilding by remember(initialMatch) {
        mutableStateOf(initialMatch?.building ?: MTUCampusData.buildings.first())
    }
    var winterSkywalkMode by remember { mutableStateOf(false) }
    var showActiveWalkingRoute by remember { mutableStateOf(true) }
    var showReferenceLandmarks by remember { mutableStateOf(true) }

    var showingIndoorMap by remember(initialMatch) {
        mutableStateOf(initialMatch != null)
    }
    var openedDirectlyToIndoor by remember(initialMatch) {
        mutableStateOf(initialMatch != null)
    }
    var indoorTargetFloor by remember(initialMatch) {
        mutableStateOf(initialMatch?.floorCode ?: "3F")
    }
    var indoorTargetRoom by remember(initialMatch) {
        mutableStateOf(initialMatch?.room)
    }

    // Pan & Zoom state for the Campus Map
    var mapZoom by remember { mutableFloatStateOf(1.0f) }
    var mapPanX by remember { mutableFloatStateOf(0f) }
    var mapPanY by remember { mutableFloatStateOf(0f) }

    LaunchedEffect(Unit) {
        ContactRepository.fetchContacts().onSuccess { fetched ->
            contacts = fetched
        }
    }

    val filteredBuildings = remember(selectedCategory, searchText, contacts) {
        MTUCampusData.buildings.filter { building ->
            val matchesCategory = (selectedCategory == MTULocationCategory.ALL) || (building.category == selectedCategory)
            val query = searchText.trim()
            if (query.isEmpty()) {
                matchesCategory
            } else {
                val matchesBuildingText =
                    building.name.contains(query, ignoreCase = true) ||
                        building.shortName.contains(query, ignoreCase = true) ||
                        building.primaryHighlight.contains(query, ignoreCase = true) ||
                        building.secondaryHighlight.contains(query, ignoreCase = true) ||
                        building.floors.flatMap { it.rooms }.any { room ->
                            room.title.contains(query, ignoreCase = true) ||
                                room.roomNumber.contains(query, ignoreCase = true) ||
                                room.subtitle.contains(query, ignoreCase = true)
                        }
                val matchesServerContact = contacts.any { contact ->
                    (contact.name.contains(query, ignoreCase = true) ||
                        contact.department.contains(query, ignoreCase = true) ||
                        (contact.office ?: "").contains(query, ignoreCase = true)) &&
                        building.matchingOfficePrefixes.any { prefix ->
                            (contact.office ?: "").contains(prefix, ignoreCase = true)
                        }
                }
                matchesCategory && (matchesBuildingText || matchesServerContact)
            }
        }
    }

    val matchingOfficeResults = remember(searchText) {
        val query = searchText.trim()
        if (query.isEmpty()) {
            emptyList()
        } else {
            val results = mutableListOf<OfficeSearchMatch>()
            for (building in MTUCampusData.buildings) {
                for (floor in building.floors) {
                    for (room in floor.rooms) {
                        if (room.title.contains(query, ignoreCase = true) ||
                            room.roomNumber.contains(query, ignoreCase = true) ||
                            room.subtitle.contains(query, ignoreCase = true) ||
                            room.roleBadge.contains(query, ignoreCase = true)
                        ) {
                            results.add(OfficeSearchMatch(building, floor.levelCode, room))
                        }
                    }
                }
            }
            results.take(8)
        }
    }

    fun openOfficeDirectly(building: MTUBuilding, floorCode: String, room: MTUFloorRoom) {
        selectedBuilding = building
        indoorTargetFloor = floorCode
        indoorTargetRoom = room
        openedDirectlyToIndoor = false
        showingIndoorMap = true
    }

    fun focusOnBuilding(building: MTUBuilding) {
        selectedBuilding = building
        showActiveWalkingRoute = true
    }

    fun openWalkingDirections(building: MTUBuilding) {
        try {
            val gmmIntentUri = Uri.parse("google.navigation:q=${building.latitude},${building.longitude}&mode=w")
            val mapIntent = Intent(Intent.ACTION_VIEW, gmmIntentUri).apply {
                setPackage("com.google.android.apps.maps")
            }
            if (mapIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(mapIntent)
            } else {
                val browserUri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${building.latitude},${building.longitude}&travelmode=walking")
                context.startActivity(Intent(Intent.ACTION_VIEW, browserUri))
            }
        } catch (_: Exception) {
        }
    }

    AnimatedContent(targetState = showingIndoorMap, label = "CampusOrIndoorMap") { isIndoor ->
        if (isIndoor) {
            MTUIndoorMapScreen(
                building = selectedBuilding,
                initialFloorCode = indoorTargetFloor,
                initialRoom = indoorTargetRoom,
                directoryContacts = contacts,
                onBackToCampusMap = {
                    openedDirectlyToIndoor = false
                    showingIndoorMap = false
                },
                onClose = {
                    if (openedDirectlyToIndoor) {
                        onClose()
                    } else {
                        showingIndoorMap = false
                    }
                }
            )
        } else {
            Scaffold(
                containerColor = lociBackground,
                topBar = {
                    TopAppBar(
                        title = {
                            Text(
                                text = "Live Interactive Map",
                                fontWeight = FontWeight.Bold,
                                fontSize = 18.sp
                            )
                        },
                        navigationIcon = {
                            TextButton(onClick = onClose) {
                                Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                            }
                        },
                        actions = {
                            TextButton(
                                onClick = {
                                    indoorTargetFloor = selectedBuilding.floors.firstOrNull()?.levelCode ?: "1F"
                                    indoorTargetRoom = selectedBuilding.floors.firstOrNull()?.rooms?.firstOrNull()
                                    openedDirectlyToIndoor = false
                                    showingIndoorMap = true
                                }
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Apartment,
                                    contentDescription = null,
                                    tint = lociAccent,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Indoor Map", color = lociAccent, fontWeight = FontWeight.Bold)
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
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // 1. Search Bar + Instant Direct-to-Office Results Strip
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        OutlinedTextField(
                            value = searchText,
                            onValueChange = { searchText = it },
                            placeholder = {
                                Text(
                                    text = "Search any office, room #, professor, or building...",
                                    fontSize = 13.sp
                                )
                            },
                            leadingIcon = {
                                Icon(Icons.Default.Search, contentDescription = null, tint = lociAccent)
                            },
                            trailingIcon = {
                                if (searchText.isNotEmpty()) {
                                    IconButton(onClick = { searchText = "" }) {
                                        Icon(Icons.Default.Cancel, contentDescription = "Clear", tint = Color.Gray)
                                    }
                                }
                            },
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                            keyboardActions = KeyboardActions(
                                onSearch = {
                                    matchingOfficeResults.firstOrNull()?.let { firstOffice ->
                                        openOfficeDirectly(firstOffice.building, firstOffice.floorCode, firstOffice.room)
                                    } ?: filteredBuildings.firstOrNull()?.let { firstMatch ->
                                        focusOnBuilding(firstMatch)
                                    }
                                }
                            ),
                            shape = RoundedCornerShape(14.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White,
                                focusedBorderColor = lociAccent,
                                unfocusedBorderColor = Color.Transparent
                            ),
                            modifier = Modifier.fillMaxWidth()
                        )

                        if (matchingOfficeResults.isNotEmpty()) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .horizontalScroll(rememberScrollState()),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                matchingOfficeResults.forEach { match ->
                                    Surface(
                                        onClick = {
                                            openOfficeDirectly(match.building, match.floorCode, match.room)
                                        },
                                        shape = CircleShape,
                                        color = Color.White.copy(alpha = 0.96f),
                                        shadowElevation = 2.dp
                                    ) {
                                        Row(
                                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            Box(
                                                modifier = Modifier
                                                    .size(18.dp)
                                                    .clip(CircleShape)
                                                    .background(match.room.kind.color),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Icon(
                                                    imageVector = Icons.Default.Apartment,
                                                    contentDescription = null,
                                                    tint = Color.White,
                                                    modifier = Modifier.size(10.dp)
                                                )
                                            }
                                            Column {
                                                Text(
                                                    text = "${match.room.title} • ${match.room.roomNumber}",
                                                    fontSize = 11.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    color = Color(0xFF1A1A2E)
                                                )
                                                Text(
                                                    text = "${match.building.shortName} (${match.floorCode}) • Tap to route inside",
                                                    fontSize = 9.5.sp,
                                                    fontWeight = FontWeight.Medium,
                                                    color = lociAccent
                                                )
                                            }
                                            Icon(
                                                imageVector = Icons.Default.NorthEast,
                                                contentDescription = null,
                                                tint = lociAccent,
                                                modifier = Modifier.size(14.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 2. Horizontal Category Filter Pills
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        MTULocationCategory.entries.forEach { category ->
                            val isSelected = (selectedCategory == category)
                            Surface(
                                onClick = {
                                    selectedCategory = category
                                    val first = MTUCampusData.buildings.firstOrNull {
                                        category == MTULocationCategory.ALL || it.category == category
                                    }
                                    if (first != null && (category != MTULocationCategory.ALL && selectedBuilding.category != category)) {
                                        focusOnBuilding(first)
                                    }
                                },
                                shape = CircleShape,
                                color = if (isSelected) category.tintColor else Color.White.copy(alpha = 0.85f),
                                modifier = Modifier.border(
                                    width = 1.dp,
                                    color = if (isSelected) Color.Transparent else category.tintColor.copy(alpha = 0.4f),
                                    shape = CircleShape
                                )
                            ) {
                                Text(
                                    text = category.rawValue,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (isSelected) Color.White else category.tintColor,
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 7.dp)
                                )
                            }
                        }
                    }

                    // 3. Winter Skywalk & Course Schedule Sync Card
                    Surface(
                        shape = RoundedCornerShape(15.dp),
                        color = Color.White.copy(alpha = 0.90f),
                        shadowElevation = 2.dp,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    ) {
                        Column(
                            modifier = Modifier.padding(10.dp),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.AcUnit,
                                        contentDescription = null,
                                        tint = lociAccent,
                                        modifier = Modifier.size(20.dp)
                                    )
                                    Column {
                                        Text(
                                            text = "Winter Skywalk & Indoor Route",
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color(0xFF1A1A2E)
                                        )
                                        Text(
                                            text = if (winterSkywalkMode) "Heated skywalks & tunnels highlighted" else "Toggle for snow-free indoor building connectors",
                                            fontSize = 10.sp,
                                            color = Color.DarkGray
                                        )
                                    }
                                }
                                Switch(
                                    checked = winterSkywalkMode,
                                    onCheckedChange = { winterSkywalkMode = it },
                                    colors = SwitchDefaults.colors(
                                        checkedThumbColor = Color.White,
                                        checkedTrackColor = lociAccent
                                    )
                                )
                            }

                            HorizontalDivider()

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(5.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.CalendarToday,
                                        contentDescription = null,
                                        tint = lociAccent,
                                        modifier = Modifier.size(13.dp)
                                    )
                                    Text(
                                        text = "Next Class: 10:13 - 11:07 • Rekhi Hall 214",
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }
                                Surface(
                                    onClick = {
                                        val rekhi = MTUCampusData.buildings.firstOrNull { it.id == "rekhi" }
                                        val floor2 = rekhi?.floors?.firstOrNull { it.levelCode == "2F" }
                                        val room214 = floor2?.rooms?.firstOrNull { it.roomNumber == "Rm 214" }
                                        if (rekhi != null && room214 != null) {
                                            winterSkywalkMode = true
                                            showActiveWalkingRoute = true
                                            openOfficeDirectly(rekhi, "2F", room214)
                                        }
                                    },
                                    shape = CircleShape,
                                    color = lociAccent.copy(alpha = 0.15f)
                                ) {
                                    Text(
                                        text = "Route to Rm 214",
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent,
                                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                    )
                                }
                            }
                        }
                    }

                    // 4. Interactive Campus Map with Differentiated Building Pins, Landmarks & Routes
                    BoxWithConstraints(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                            .shadow(4.dp, RoundedCornerShape(20.dp))
                            .clip(RoundedCornerShape(20.dp))
                            .background(Color(0xFFEAF2E8))
                            .border(
                                width = if (winterSkywalkMode) 2.5.dp else 1.dp,
                                color = if (winterSkywalkMode) lociAccent.copy(alpha = 0.55f) else Color.White.copy(alpha = 0.7f),
                                shape = RoundedCornerShape(20.dp)
                            )
                            .pointerInput(Unit) {
                                detectTransformGestures { _, pan, zoom, _ ->
                                    mapZoom = (mapZoom * zoom).coerceIn(0.75f, 2.8f)
                                    mapPanX = (mapPanX + pan.x).coerceIn(-450f, 450f)
                                    mapPanY = (mapPanY + pan.y).coerceIn(-350f, 350f)
                                }
                            }
                    ) {
                        val wPx = constraints.maxWidth.toFloat()
                        val hPx = constraints.maxHeight.toFloat()
                        val wDp = maxWidth
                        val hDp = maxHeight

                        // Geographic bounding box covering MTU campus (from Lakeshore Center west to Wads east, SDC south to Portage Lake north)
                        val minLon = -88.5565
                        val maxLon = -88.5422
                        val minLat = 47.1140
                        val maxLat = 47.1218

                        fun project(coord: LatLngCoord): Offset {
                            val normX = ((coord.longitude - minLon) / (maxLon - minLon)).toFloat()
                            val normY = (1.0 - (coord.latitude - minLat) / (maxLat - minLat)).toFloat()
                            val baseX = wPx * (0.08f + normX * 0.84f)
                            val baseY = hPx * (0.10f + normY * 0.80f)
                            val cx = wPx / 2f
                            val cy = hPx / 2f
                            return Offset(
                                x = cx + (baseX - cx) * mapZoom + mapPanX,
                                y = cy + (baseY - cy) * mapZoom + mapPanY
                            )
                        }

                        Canvas(modifier = Modifier.fillMaxSize()) {
                            // 1. Portage Lake Waterway along North Shoreline
                            val lakeBottomRight = project(LatLngCoord(47.1202, -88.5415))
                            drawRect(
                                color = Color(0xFFB5DCF4),
                                topLeft = Offset(0f, 0f),
                                size = Size(wPx, lakeBottomRight.y.coerceAtLeast(36f))
                            )

                            // 2. Campus Quad Greenspace
                            val quadTL = project(LatLngCoord(47.1196, -88.5502))
                            val quadBR = project(LatLngCoord(47.1180, -88.5442))
                            drawRoundRect(
                                color = Color(0xFFD5EAD0),
                                topLeft = quadTL,
                                size = Size(
                                    (quadBR.x - quadTL.x).coerceAtLeast(40f),
                                    (quadBR.y - quadTL.y).coerceAtLeast(40f)
                                ),
                                cornerRadius = androidx.compose.ui.geometry.CornerRadius(24f, 24f)
                            )

                            // 3. U.S. Highway 41 & Townsend Drive Loop Roads
                            val roadPath = Path().apply {
                                val p1 = project(LatLngCoord(47.1212, -88.5565))
                                val p2 = project(LatLngCoord(47.1199, -88.5495))
                                val p3 = project(LatLngCoord(47.1194, -88.5450))
                                val p4 = project(LatLngCoord(47.1178, -88.5425))
                                moveTo(p1.x, p1.y)
                                lineTo(p2.x, p2.y)
                                lineTo(p3.x, p3.y)
                                lineTo(p4.x, p4.y)
                            }
                            drawPath(
                                path = roadPath,
                                color = Color(0xFFF6D992),
                                style = Stroke(width = 7.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round)
                            )

                            val townsendPath = Path().apply {
                                val t1 = project(LatLngCoord(47.1195, -88.5508))
                                val t2 = project(LatLngCoord(47.1183, -88.5482))
                                val t3 = project(LatLngCoord(47.1182, -88.5452))
                                val t4 = project(LatLngCoord(47.1173, -88.5430))
                                moveTo(t1.x, t1.y)
                                lineTo(t2.x, t2.y)
                                lineTo(t3.x, t3.y)
                                lineTo(t4.x, t4.y)
                            }
                            drawPath(
                                path = townsendPath,
                                color = Color.White.copy(alpha = 0.9f),
                                style = Stroke(width = 5.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round)
                            )

                            // A. Heated Skywalk Network Polylines
                            if (winterSkywalkMode) {
                                MTUCampusData.skywalkSegments.forEach { seg ->
                                    val fromPt = project(seg.fromCoord)
                                    val toPt = project(seg.toCoord)
                                    drawLine(
                                        color = Color(0xFF00BCD4),
                                        start = fromPt,
                                        end = toPt,
                                        strokeWidth = 4.5.dp.toPx(),
                                        cap = StrokeCap.Round,
                                        pathEffect = PathEffect.dashPathEffect(floatArrayOf(16f, 12f), 0f)
                                    )
                                }
                            }

                            // B. Active Campus Walking Route Polyline from Central Hub to Selected Building
                            if (showActiveWalkingRoute) {
                                val routeCoords = MTUCampusData.campusRouteCoordinates(selectedBuilding, winterSkywalkMode)
                                if (routeCoords.size >= 2) {
                                    val routePath = Path().apply {
                                        val first = project(routeCoords.first())
                                        moveTo(first.x, first.y)
                                        routeCoords.drop(1).forEach { c ->
                                            val pt = project(c)
                                            lineTo(pt.x, pt.y)
                                        }
                                    }
                                    drawPath(
                                        path = routePath,
                                        color = lociAccent.copy(alpha = 0.28f),
                                        style = Stroke(width = 9.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round)
                                    )
                                    drawPath(
                                        path = routePath,
                                        color = lociAccent,
                                        style = Stroke(
                                            width = 4.5.dp.toPx(),
                                            cap = StrokeCap.Round,
                                            join = StrokeJoin.Round,
                                            pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 12f), 0f)
                                        )
                                    )
                                }
                            }
                        }

                        // C. Spatial Reference Landmarks & Shuttle Stops
                        if (showReferenceLandmarks) {
                            MTUCampusData.campusLandmarks.forEach { landmark ->
                                val pt = project(landmark.coordinate)
                                val xDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.x.toDp() } - 48.dp
                                val yDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.y.toDp() } - 10.dp
                                Surface(
                                    shape = CircleShape,
                                    color = Color.White.copy(alpha = 0.90f),
                                    modifier = Modifier
                                        .offset(x = xDp, y = yDp)
                                        .border(1.dp, Color(0xFFFF9800).copy(alpha = 0.5f), CircleShape)
                                ) {
                                    Text(
                                        text = "★ ${landmark.name}",
                                        fontSize = 8.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color(0xFFE65100),
                                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                    )
                                }
                            }

                            MTUCampusData.shuttleStops.forEach { stop ->
                                val pt = project(stop.coordinate)
                                val xDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.x.toDp() } - 22.dp
                                val yDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.y.toDp() } - 10.dp
                                Surface(
                                    shape = CircleShape,
                                    color = Color.White.copy(alpha = 0.94f),
                                    modifier = Modifier
                                        .offset(x = xDp, y = yDp)
                                        .border(1.dp, Color(0xFF1976D2).copy(alpha = 0.45f), CircleShape)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(2.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.DirectionsBus,
                                            contentDescription = null,
                                            tint = Color(0xFF1976D2),
                                            modifier = Modifier.size(9.dp)
                                        )
                                        Text(
                                            text = "${stop.etaMinutes}m",
                                            fontSize = 8.sp,
                                            fontWeight = FontWeight.Black,
                                            color = Color(0xFF1976D2)
                                        )
                                    }
                                }
                            }
                        }

                        // D. Differentiated Campus Building Pins with Building # and Category Color
                        filteredBuildings.forEach { building ->
                            val isSelected = (selectedBuilding.id == building.id)
                            val catColor = building.category.tintColor
                            val pt = project(building.coordinate)
                            val xDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.x.toDp() } - 48.dp
                            val yDp = with(androidx.compose.ui.platform.LocalDensity.current) { pt.y.toDp() } - 14.dp
                            val scale by animateFloatAsState(
                                targetValue = if (isSelected) 1.08f else 1.0f,
                                animationSpec = spring(stiffness = Spring.StiffnessMedium),
                                label = "PinScale"
                            )

                            Surface(
                                onClick = { focusOnBuilding(building) },
                                shape = CircleShape,
                                color = if (isSelected) lociAccent else Color.White,
                                shadowElevation = if (isSelected) 6.dp else 3.dp,
                                modifier = Modifier
                                    .offset(x = xDp, y = yDp)
                                    .scale(scale)
                                    .border(
                                        width = if (isSelected) 1.5.dp else 1.dp,
                                        color = if (isSelected) Color.White else catColor.copy(alpha = 0.6f),
                                        shape = CircleShape
                                    )
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 7.dp, vertical = 4.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Surface(
                                        shape = CircleShape,
                                        color = if (isSelected) Color.White.copy(alpha = 0.25f) else catColor.copy(alpha = 0.16f)
                                    ) {
                                        Text(
                                            text = "#${building.buildingNumber}",
                                            fontSize = 8.5.sp,
                                            fontWeight = FontWeight.Black,
                                            color = if (isSelected) Color.White else catColor,
                                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                                        )
                                    }
                                    Text(
                                        text = building.shortName,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = if (isSelected) Color.White else Color(0xFF1A1A2E),
                                        maxLines = 1
                                    )
                                    if (building.hasSkywalkAccess && winterSkywalkMode) {
                                        Icon(
                                            imageVector = Icons.Default.AcUnit,
                                            contentDescription = null,
                                            tint = if (isSelected) Color.White else Color(0xFF00BCD4),
                                            modifier = Modifier.size(10.dp)
                                        )
                                    }
                                }
                            }
                        }

                        // Top Floating Map Controls (Reference Landmarks Toggle + Shuttle Pill)
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .align(Alignment.TopCenter)
                                .padding(10.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                onClick = { showReferenceLandmarks = !showReferenceLandmarks },
                                shape = CircleShape,
                                color = Color.White.copy(alpha = 0.94f),
                                shadowElevation = 3.dp
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = if (showReferenceLandmarks) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                        contentDescription = null,
                                        tint = lociAccent,
                                        modifier = Modifier.size(13.dp)
                                    )
                                    Text(
                                        text = if (showReferenceLandmarks) "Landmarks On" else "Landmarks Off",
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }
                            }

                            Surface(
                                shape = CircleShape,
                                color = Color.White.copy(alpha = 0.94f),
                                shadowElevation = 3.dp
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(5.dp)
                                ) {
                                    Text(
                                        text = "Husky Shuttle • 2m 🚌",
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color(0xFF1A1A2E)
                                    )
                                }
                            }
                        }

                        // Bottom-Right Map Zoom & Route Toggle Controls
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .align(Alignment.BottomCenter)
                                .padding(10.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            Surface(
                                onClick = { showActiveWalkingRoute = !showActiveWalkingRoute },
                                shape = CircleShape,
                                color = Color.White.copy(alpha = 0.94f),
                                shadowElevation = 3.dp
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(5.dp)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(8.dp)
                                            .clip(CircleShape)
                                            .background(if (showActiveWalkingRoute) lociAccent else Color.Gray)
                                    )
                                    Text(
                                        text = if (showActiveWalkingRoute) "Route to #${selectedBuilding.buildingNumber} Active" else "Show Campus Route",
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }
                            }

                            Surface(
                                shape = RoundedCornerShape(12.dp),
                                color = Color.White.copy(alpha = 0.94f),
                                shadowElevation = 4.dp
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    IconButton(
                                        onClick = { mapZoom = (mapZoom * 1.25f).coerceAtMost(2.8f) },
                                        modifier = Modifier.size(34.dp)
                                    ) {
                                        Icon(Icons.Default.Add, contentDescription = "Zoom In", modifier = Modifier.size(16.dp))
                                    }
                                    HorizontalDivider(modifier = Modifier.width(24.dp))
                                    IconButton(
                                        onClick = {
                                            mapZoom = (mapZoom * 0.8f).coerceAtLeast(0.75f)
                                            if (mapZoom <= 1.0f) {
                                                mapPanX = 0f
                                                mapPanY = 0f
                                            }
                                        },
                                        modifier = Modifier.size(34.dp)
                                    ) {
                                        Icon(Icons.Default.Remove, contentDescription = "Zoom Out", modifier = Modifier.size(16.dp))
                                    }
                                }
                            }
                        }
                    }

                    // 5. Bottom Building / Spatial Reference / Indoor Floor Plan Card
                    val totalRoomsCount = selectedBuilding.floors.sumOf { it.rooms.size }
                    Surface(
                        shape = RoundedCornerShape(22.dp),
                        color = Color.White,
                        shadowElevation = 6.dp,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
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
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                                    ) {
                                        Surface(
                                            shape = CircleShape,
                                            color = selectedBuilding.category.tintColor.copy(alpha = 0.15f)
                                        ) {
                                            Text(
                                                text = "Bldg #${selectedBuilding.buildingNumber}",
                                                fontSize = 10.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = selectedBuilding.category.tintColor,
                                                modifier = Modifier.padding(horizontal = 7.dp, vertical = 2.dp)
                                            )
                                        }
                                        Text(
                                            text = selectedBuilding.name,
                                            fontSize = 14.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color(0xFF1A1A2E),
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                    Text(
                                        text = selectedBuilding.relativeCampusDescription,
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = lociAccent,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }

                                Surface(
                                    shape = CircleShape,
                                    color = Color(0xFF2E7D32).copy(alpha = 0.14f)
                                ) {
                                    Text(
                                        text = "${selectedBuilding.floors.size} Floors • $totalRoomsCount Rooms",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color(0xFF2E7D32),
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                    )
                                }
                            }

                            if (winterSkywalkMode) {
                                Surface(
                                    shape = RoundedCornerShape(11.dp),
                                    color = lociBackground.copy(alpha = 0.38f),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Column(
                                        modifier = Modifier.padding(9.dp),
                                        verticalArrangement = Arrangement.spacedBy(3.dp)
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween
                                        ) {
                                            Text(
                                                text = "❄️ Winter Indoor/Connector Route",
                                                fontSize = 10.5.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = lociAccent
                                            )
                                            Text(
                                                text = "${selectedBuilding.walkMinutesIndoor} min walk • Avoids snow",
                                                fontSize = 10.5.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = lociAccent
                                            )
                                        }
                                        Text(
                                            text = selectedBuilding.skywalkRouteSummary,
                                            fontSize = 11.5.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color(0xFF1A1A2E)
                                        )
                                    }
                                }
                            } else {
                                Surface(
                                    shape = RoundedCornerShape(11.dp),
                                    color = Color.LightGray.copy(alpha = 0.22f),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Column(
                                        modifier = Modifier.padding(9.dp),
                                        verticalArrangement = Arrangement.spacedBy(2.dp)
                                    ) {
                                        Text(
                                            text = selectedBuilding.primaryHighlight,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color(0xFF1A1A2E)
                                        )
                                        Text(
                                            text = selectedBuilding.secondaryHighlight,
                                            fontSize = 11.sp,
                                            color = Color.DarkGray
                                        )
                                    }
                                }
                            }

                            // Action Row: Open Indoor Floor Plan & Route + Google Maps GPS
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Surface(
                                    onClick = {
                                        indoorTargetFloor = selectedBuilding.floors.firstOrNull()?.levelCode ?: "1F"
                                        indoorTargetRoom = selectedBuilding.floors.firstOrNull()?.rooms?.firstOrNull()
                                        openedDirectlyToIndoor = false
                                        showingIndoorMap = true
                                    },
                                    shape = CircleShape,
                                    color = lociAccent,
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(vertical = 12.dp, horizontal = 10.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.Center
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Apartment,
                                            contentDescription = null,
                                            tint = Color.White,
                                            modifier = Modifier.size(16.dp)
                                        )
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text(
                                            text = "Explore Indoor Floor Plan ($totalRoomsCount Offices)",
                                            fontSize = 11.5.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color.White
                                        )
                                    }
                                }

                                Surface(
                                    onClick = { openWalkingDirections(selectedBuilding) },
                                    shape = CircleShape,
                                    color = lociAccent.copy(alpha = 0.15f)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 13.dp, vertical = 12.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.NearMe,
                                            contentDescription = "GPS",
                                            tint = lociAccent,
                                            modifier = Modifier.size(14.dp)
                                        )
                                        val mins = if (winterSkywalkMode) selectedBuilding.walkMinutesIndoor else selectedBuilding.walkMinutesOutdoor
                                        Text(
                                            text = "${mins}m GPS",
                                            fontSize = 11.5.sp,
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
}
