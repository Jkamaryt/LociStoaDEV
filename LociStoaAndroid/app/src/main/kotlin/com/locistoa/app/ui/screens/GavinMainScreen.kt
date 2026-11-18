package com.locistoa.app.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.automirrored.filled.OpenInNew
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Apartment
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DeleteOutline
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Flag
import androidx.compose.material.icons.filled.Fullscreen
import androidx.compose.material.icons.filled.HelpOutline
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material.icons.filled.WorkOutline
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.locistoa.app.data.Contact
import com.locistoa.app.data.ContactRepository
import com.locistoa.app.data.GavinActiveSheet
import com.locistoa.app.data.GavinMapBuilding
import com.locistoa.app.data.GavinMapViewMode
import com.locistoa.app.data.GavinPerson
import com.locistoa.app.data.GavinPlanMode
import com.locistoa.app.data.GavinPeopleSubView
import com.locistoa.app.data.GavinStore
import com.locistoa.app.data.GavinTab
import com.locistoa.app.data.MTUCampusData
import com.locistoa.app.ui.theme.GavinDisplayFontFamily
import com.locistoa.app.ui.theme.GavinHeroWavesDecoration
import com.locistoa.app.ui.theme.GavinSecondaryButton
import com.locistoa.app.ui.theme.LociBrandState
import com.locistoa.app.ui.theme.LociTheme
import com.locistoa.app.ui.theme.ModernButton
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GavinMainScreen(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onLocateContactOnMap: (Contact) -> Unit,
    onSignOut: () -> Unit
) {
    var showAdminModal by remember { mutableStateOf(false) }

    // Auto-dismiss undo toast after 4.5s
    LaunchedEffect(store.toast) {
        if (store.toast != null) {
            delay(4500)
            store.toast = null
        }
    }

    val bg = LociBrandState.background
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(bg)
            .statusBarsPadding()
            .navigationBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Main Tab Body
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                when (store.tab) {
                    GavinTab.HOME -> GavinHomeTab(
                        store = store,
                        onOpenDestination = onOpenDestination,
                        onLocateContactOnMap = onLocateContactOnMap
                    )
                    GavinTab.PEOPLE -> GavinPeopleTab(
                        store = store,
                        onOpenDestination = onOpenDestination,
                        onLocateContactOnMap = onLocateContactOnMap
                    )
                    GavinTab.MAP -> GavinMapTab(
                        store = store,
                        onOpenDestination = onOpenDestination,
                        onLocateContactOnMap = onLocateContactOnMap
                    )
                    GavinTab.PLANNER -> GavinPlannerTab(
                        store = store,
                        onOpenDestination = onOpenDestination
                    )
                    GavinTab.MORE -> GavinMoreTab(
                        store = store,
                        onOpenDestination = onOpenDestination,
                        onOpenAdminSettings = { showAdminModal = true },
                        onSignOut = onSignOut
                    )
                }

                // Floating Toast ("Marked done · Undo")
                androidx.compose.animation.AnimatedVisibility(
                    visible = store.toast != null,
                    enter = fadeIn(),
                    exit = fadeOut(),
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(bottom = 12.dp)
                ) {
                    store.toast?.let { (msg, taskId) ->
                        Surface(
                            shape = CircleShape,
                            color = ink,
                            shadowElevation = 6.dp
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(14.dp)
                            ) {
                                Text(
                                    text = msg,
                                    color = Color.White,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    text = "Undo",
                                    color = LociBrandState.h2,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    modifier = Modifier.clickable {
                                        store.toggleTask(taskId)
                                        store.toast = null
                                    }
                                )
                            }
                        }
                    }
                }
            }

            // Pinned Bottom Search Bar + 5-Tab Bar (Exact match to Main.dc.html .dock)
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .border(width = 1.dp, color = line)
            ) {
                // Search Bar Trigger
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(tint.copy(alpha = 0.7f))
                        .border(1.dp, line, RoundedCornerShape(12.dp))
                        .clickable {
                            store.query = ""
                            store.sheet = GavinActiveSheet.SEARCH
                        }
                        .padding(horizontal = 12.dp, vertical = 10.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Search",
                            tint = sub,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Search people, offices, clubs, lingo…",
                            color = sub,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }

                HorizontalDivider(color = LociBrandState.rule)

                // 5-Tab Navigation Bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 6.dp, horizontal = 4.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    GavinTab.entries.forEach { tabItem ->
                        val selected = store.tab == tabItem
                        val iconVec: ImageVector = when (tabItem) {
                            GavinTab.HOME -> Icons.Default.Home
                            GavinTab.PEOPLE -> Icons.Default.People
                            GavinTab.MAP -> Icons.Default.Map
                            GavinTab.PLANNER -> Icons.Default.CalendarMonth
                            GavinTab.MORE -> Icons.Default.MoreHoriz
                        }
                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(10.dp))
                                .clickable {
                                    store.go(
                                        targetTab = tabItem,
                                        resetPeopleSelection = (tabItem == GavinTab.PEOPLE && store.tab == GavinTab.PEOPLE)
                                    )
                                }
                                .padding(vertical = 4.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .clip(CircleShape)
                                    .background(if (selected) tint else Color.Transparent)
                                    .padding(horizontal = 14.dp, vertical = 4.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = iconVec,
                                    contentDescription = tabItem.label,
                                    tint = if (selected) accent else sub,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                            Text(
                                text = tabItem.label,
                                color = if (selected) accent else sub,
                                fontSize = 11.sp,
                                fontWeight = if (selected) FontWeight.ExtraBold else FontWeight.Medium
                            )
                        }
                    }
                }
            }
        }
    }

    // Active Gavin Sheets
    when (store.sheet) {
        GavinActiveSheet.EMERGENCY -> {
            ModalBottomSheet(
                onDismissRequest = { store.sheet = null },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                containerColor = Color.White
            ) {
                GavinEmergencySheetContent(onClose = { store.sheet = null })
            }
        }
        GavinActiveSheet.CONTACT -> {
            val person = store.currentContact
            if (person != null) {
                ModalBottomSheet(
                    onDismissRequest = { store.sheet = null },
                    sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                    containerColor = Color.White
                ) {
                    GavinContactSheetContent(
                        store = store,
                        person = person,
                        onLocateOnInteractiveMap = {
                            val c = store.contactForPerson(person)
                            store.sheet = null
                            onLocateContactOnMap(c)
                        },
                        onClose = { store.sheet = null }
                    )
                }
            }
        }
        GavinActiveSheet.ADD_TASK -> {
            ModalBottomSheet(
                onDismissRequest = { store.sheet = null },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                containerColor = Color.White
            ) {
                GavinAddTaskSheetContent(
                    store = store,
                    onClose = { store.sheet = null }
                )
            }
        }
        GavinActiveSheet.ADD_CLASS -> {
            ModalBottomSheet(
                onDismissRequest = { store.sheet = null },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                containerColor = Color.White
            ) {
                GavinAddClassSheetContent(
                    store = store,
                    onClose = { store.sheet = null }
                )
            }
        }
        GavinActiveSheet.SEARCH -> {
            ModalBottomSheet(
                onDismissRequest = { store.sheet = null },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                containerColor = Color.White
            ) {
                GavinSearchModalContent(
                    store = store,
                    onOpenDestination = { dest ->
                        store.sheet = null
                        onOpenDestination(dest)
                    },
                    onClose = { store.sheet = null }
                )
            }
        }
        null -> {}
    }

    if (showAdminModal) {
        ModalBottomSheet(
            onDismissRequest = { showAdminModal = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = LociBrandState.background
        ) {
            AdminSettingsContent(onClose = { showAdminModal = false })
        }
    }
}

// ============================================================================
// 1. HOME TAB (Exact match to GavinHomeTabView in Swift + All 8 Original Tools)
// ============================================================================
@Composable
private fun GavinHomeTab(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onLocateContactOnMap: (Contact) -> Unit
) {
    val context = LocalContext.current
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent
    val word = LociBrandState.word

    val todayText = remember {
        SimpleDateFormat("EEEE, MMMM d", Locale.US).format(Date())
    }

    fun openExternalUrl(url: String) {
        try {
            context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        } catch (_: Exception) {
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Gavin Hero Card
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(18.dp))
                .background(Color.White)
                .border(1.dp, line, RoundedCornerShape(18.dp))
        ) {
            GavinHeroWavesDecoration(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(130.dp)
            )

            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text = "MICHIGAN TECHNOLOGICAL UNIVERSITY",
                    color = sub,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.8.sp
                )
                Text(
                    text = "LociStoa",
                    color = word,
                    fontSize = 30.sp,
                    fontFamily = GavinDisplayFontFamily,
                    fontWeight = FontWeight.Black
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = todayText,
                        color = ink,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Surface(
                        onClick = { store.sheet = GavinActiveSheet.EMERGENCY },
                        shape = CircleShape,
                        color = Color(0xFFFDECEC),
                        border = androidx.compose.foundation.BorderStroke(1.dp, Color(0xFFF5B5B5))
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(5.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Phone,
                                contentDescription = "Emergency",
                                tint = Color(0xFFB42318),
                                modifier = Modifier.size(13.dp)
                            )
                            Text(
                                text = "Emergency",
                                color = Color(0xFFB42318),
                                fontSize = 11.sp,
                                fontWeight = FontWeight.ExtraBold
                            )
                        }
                    }
                }
            }
        }

        // Widget: Next Class
        if (store.isWidgetEnabled("next")) {
            val nextInfo = store.nextClassInfo
            Surface(
                onClick = {
                    store.go(GavinTab.PLANNER, targetPlanMode = GavinPlanMode.TIMES)
                },
                shape = RoundedCornerShape(16.dp),
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                modifier = Modifier.fillMaxWidth()
            ) {
                if (nextInfo != null) {
                    val (code, lineText, label) = nextInfo
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(3.dp)
                        ) {
                            Text(
                                text = label.uppercase(),
                                color = accent,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.ExtraBold
                            )
                            Text(
                                text = code,
                                color = ink,
                                fontSize = 18.sp,
                                fontFamily = GavinDisplayFontFamily,
                                fontWeight = FontWeight.ExtraBold
                            )
                            Text(
                                text = lineText,
                                color = sub,
                                fontSize = 12.sp
                            )
                        }
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                            contentDescription = null,
                            tint = sub
                        )
                    }
                } else {
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(38.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(tint),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.Schedule, contentDescription = null, tint = accent)
                        }
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Add your classes", color = ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                            Text("Put your schedule on the home screen", color = sub, fontSize = 12.sp)
                        }
                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub)
                    }
                }
            }
        }

        // Widget: This Week Calendar
        if (store.isWidgetEnabled("cal")) {
            GavinCardSection(
                title = "This week",
                actionLabel = if (store.classes.isEmpty()) "+ Add class" else "All classes",
                onAction = {
                    if (store.classes.isEmpty()) {
                        store.sheet = GavinActiveSheet.ADD_CLASS
                    } else {
                        store.go(GavinTab.PLANNER, targetPlanMode = GavinPlanMode.TIMES)
                    }
                }
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    store.weekCalendarDays.forEach { day ->
                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(11.dp))
                                .background(if (day.on) accent else tint.copy(alpha = 0.55f))
                                .border(
                                    1.dp,
                                    if (day.on) accent else line,
                                    RoundedCornerShape(11.dp)
                                )
                                .clickable { store.calDay = day.index }
                                .padding(vertical = 8.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Text(
                                text = day.top,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (day.on) Color.White.copy(alpha = 0.85f) else sub
                            )
                            Text(
                                text = "${day.num}",
                                fontSize = 15.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = if (day.on) Color.White else ink
                            )
                            Text(
                                text = day.dots.ifEmpty { " " },
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Black,
                                color = if (day.on) Color.White else accent
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                val dayClasses = store.selectedCalDayClasses
                if (dayClasses.isEmpty()) {
                    Text(
                        text = if (store.classes.isEmpty()) "Add your classes to fill in the week." else "No classes scheduled on this day.",
                        color = sub,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(vertical = 4.dp)
                    )
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        dayClasses.forEach { entry ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(tint.copy(alpha = 0.45f))
                                    .padding(horizontal = 12.dp, vertical = 8.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(entry.code, color = ink, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                    Text(entry.name, color = sub, fontSize = 11.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                }
                                Column(horizontalAlignment = Alignment.End) {
                                    Text(entry.time, color = ink, fontWeight = FontWeight.SemiBold, fontSize = 11.sp)
                                    if (entry.item.loc.isNotBlank()) {
                                        Text(entry.item.loc, color = accent, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Widget: Due Soon Tasks
        if (store.isWidgetEnabled("due")) {
            val dueList = store.dueSoonTasks
            GavinCardSection(
                title = "Due soon",
                actionLabel = if (dueList.isEmpty()) "+ Add task" else "Open planner",
                onAction = {
                    if (dueList.isEmpty()) {
                        store.sheet = GavinActiveSheet.ADD_TASK
                    } else {
                        store.go(GavinTab.PLANNER, targetPlanMode = GavinPlanMode.TASKS)
                    }
                }
            ) {
                if (dueList.isEmpty()) {
                    Text(
                        text = "Nothing due right now.",
                        color = sub,
                        fontSize = 12.sp
                    )
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        dueList.forEach { task ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(tint.copy(alpha = 0.4f))
                                    .clickable { store.toggleTask(task.id) }
                                    .padding(10.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                Icon(
                                    imageVector = if (task.done) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
                                    contentDescription = null,
                                    tint = if (task.done) accent else LociBrandState.check,
                                    modifier = Modifier.size(20.dp)
                                )
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "${task.type} · ${task.course}",
                                        color = ink,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp
                                    )
                                    if (task.description.isNotBlank()) {
                                        Text(
                                            text = task.description,
                                            color = sub,
                                            fontSize = 11.sp,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                }
                                Surface(
                                    shape = CircleShape,
                                    color = Color.White,
                                    border = androidx.compose.foundation.BorderStroke(1.dp, line)
                                ) {
                                    Text(
                                        text = task.due,
                                        color = sub,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        // Widget: Campus Tools (All 8 Original LociStoa Dashboard Features!)
        if (store.isWidgetEnabled("tools")) {
            GavinCardSection(
                title = "Campus tools",
                actionLabel = "All tools",
                onAction = { store.go(GavinTab.MORE) }
            ) {
                val tools = listOf(
                    Triple("Live Map", "GPS & Indoor", Icons.Default.Map) to {
                        onOpenDestination(DashboardDestination.MAP)
                    },
                    Triple("Directory", "Faculty & Staff", Icons.Default.People) to {
                        onOpenDestination(DashboardDestination.DIRECTORY)
                    },
                    Triple("TaskFlow", "Homework Planner", Icons.Default.CalendarMonth) to {
                        onOpenDestination(DashboardDestination.HOMEWORK_PLANNER)
                    },
                    Triple("Schedule", "Periods 1–8", Icons.Default.Schedule) to {
                        onOpenDestination(DashboardDestination.SCHEDULE)
                    },
                    Triple("Career Fair", "Company Booths", Icons.Default.WorkOutline) to {
                        onOpenDestination(DashboardDestination.CAREER_FAIR)
                    },
                    Triple("Common Links", "Canvas & Banweb", Icons.Default.Link) to {
                        onOpenDestination(DashboardDestination.COMMON_LINKS)
                    },
                    Triple("Ask LociStoa", "Campus Chatbot", Icons.Default.SmartToy) to {
                        onOpenDestination(DashboardDestination.CHATBOT)
                    },
                    Triple("Nomenclature", "Campus Lingo", Icons.Default.Book) to {
                        onOpenDestination(DashboardDestination.NOMENCLATURE)
                    }
                )

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    tools.chunked(2).forEach { pair ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            pair.forEach { (info, action) ->
                                val (title, subtitle, icon) = info
                                Surface(
                                    onClick = action,
                                    shape = RoundedCornerShape(12.dp),
                                    color = tint.copy(alpha = 0.55f),
                                    border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(10.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(9.dp)
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .size(32.dp)
                                                .clip(RoundedCornerShape(8.dp))
                                                .background(Color.White),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Icon(
                                                imageVector = icon,
                                                contentDescription = title,
                                                tint = accent,
                                                modifier = Modifier.size(17.dp)
                                            )
                                        }
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = title,
                                                color = ink,
                                                fontWeight = FontWeight.Bold,
                                                fontSize = 12.sp,
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
                                            )
                                            Text(
                                                text = subtitle,
                                                color = sub,
                                                fontSize = 10.sp,
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
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

        // Widget: Quick Links
        if (store.isWidgetEnabled("links")) {
            GavinCardSection(
                title = "Quick links",
                actionLabel = "Full view",
                onAction = { onOpenDestination(DashboardDestination.COMMON_LINKS) }
            ) {
                val links = listOf(
                    Triple("Canvas", "Courses & grades", "https://mtu.instructure.com"),
                    Triple("Banweb", "Registration & aid", "https://banweb.mtu.edu"),
                    Triple("MyMichiganTech", "Student portal", "https://mymichigantech.mtu.edu"),
                    Triple("Academic Calendar", "Key semester dates", "https://www.mtu.edu/registrar/students/calendars/")
                )
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    links.chunked(2).forEach { rowLinks ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            rowLinks.forEach { (name, desc, url) ->
                                Surface(
                                    onClick = { openExternalUrl(url) },
                                    shape = RoundedCornerShape(12.dp),
                                    color = tint.copy(alpha = 0.45f),
                                    border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(11.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(name, color = ink, fontWeight = FontWeight.Bold, fontSize = 12.sp, maxLines = 1)
                                            Text(desc, color = sub, fontSize = 10.sp, maxLines = 1)
                                        }
                                        Icon(
                                            imageVector = Icons.AutoMirrored.Filled.OpenInNew,
                                            contentDescription = null,
                                            tint = accent,
                                            modifier = Modifier.size(14.dp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Widget: Get Help Shortcuts
        if (store.isWidgetEnabled("help")) {
            GavinCardSection(
                title = "Need a hand?",
                actionLabel = "All offices",
                onAction = {
                    store.go(GavinTab.PEOPLE, subView = GavinPeopleSubView.HELP, resetPeopleSelection = true)
                }
            ) {
                val shortcuts = listOf(
                    "advising" to "Academic advising",
                    "learning-centers" to "Tutoring / Learning Centers",
                    "finaid" to "Financial Aid & billing",
                    "registrar" to "Registrar",
                    "counseling" to "Counseling & wellness",
                    "it-help" to "IT Help"
                )
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    shortcuts.forEach { (officeId, title) ->
                        Surface(
                            onClick = {
                                store.go(
                                    targetTab = GavinTab.PEOPLE,
                                    subView = GavinPeopleSubView.HELP,
                                    resetPeopleSelection = true,
                                    targetOffice = officeId
                                )
                            },
                            shape = RoundedCornerShape(10.dp),
                            color = tint.copy(alpha = 0.4f),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 9.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(title, color = ink, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
                                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub, modifier = Modifier.size(18.dp))
                            }
                        }
                    }
                }
            }
        }

        // Widget: Saved People
        if (store.isWidgetEnabled("saved")) {
            val saved = store.savedContacts
            GavinCardSection(
                title = "Saved people",
                actionLabel = "Directory",
                onAction = {
                    store.go(GavinTab.PEOPLE, subView = GavinPeopleSubView.DIR, resetPeopleSelection = true)
                }
            ) {
                if (saved.isEmpty()) {
                    Text(
                        text = "Tap the bookmark on any contact to pin them here.",
                        color = sub,
                        fontSize = 12.sp
                    )
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        saved.forEach { person ->
                            GavinPersonRow(
                                person = person,
                                onClick = {
                                    store.contactId = person.id
                                    store.sheet = GavinActiveSheet.CONTACT
                                },
                                onLocateOnMap = {
                                    onLocateContactOnMap(store.contactForPerson(person))
                                }
                            )
                        }
                    }
                }
            }
        }

        // Widget: Student Org of the Day
        if (store.isWidgetEnabled("org")) {
            store.orgOfTheDay?.let { org ->
                GavinCardSection(
                    title = "Student org of the day",
                    actionLabel = "All orgs",
                    onAction = {
                        store.go(GavinTab.PEOPLE, subView = GavinPeopleSubView.ORGS, resetPeopleSelection = true)
                    }
                ) {
                    Surface(
                        onClick = {
                            store.go(
                                targetTab = GavinTab.PEOPLE,
                                subView = GavinPeopleSubView.ORGS,
                                resetPeopleSelection = true,
                                targetOrg = org.i
                            )
                        },
                        shape = RoundedCornerShape(12.dp),
                        color = tint.copy(alpha = 0.45f),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(org.cat.uppercase(), color = accent, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                            Text(org.name, color = ink, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                            Text(org.desc, color = sub, fontSize = 12.sp, maxLines = 2, overflow = TextOverflow.Ellipsis)
                        }
                    }
                }
            }
        }
    }
}

// ============================================================================
// 2. PEOPLE TAB (Directory, Get Help, Departments, Student Orgs + Server Sync)
// ============================================================================
@Composable
private fun GavinPeopleTab(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onLocateContactOnMap: (Contact) -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 14.dp, vertical = 10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Top Segmented Switcher (Directory | Get help | Departments | Student orgs)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Color.White)
                .border(1.dp, line, RoundedCornerShape(12.dp))
                .padding(3.dp),
            horizontalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            GavinPeopleSubView.entries.forEach { mode ->
                val active = store.pv == mode
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(9.dp))
                        .background(if (active) accent else Color.Transparent)
                        .clickable {
                            store.pv = mode
                            store.dept = null
                            store.office = null
                            store.org = null
                        }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = mode.label,
                        color = if (active) Color.White else ink,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1
                    )
                }
            }
        }

        when (store.pv) {
            GavinPeopleSubView.DIR -> {
                // Header Row with Sync Server & Full View
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Directory",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        Surface(
                            onClick = {
                                scope.launch {
                                    store.isSyncingServer = true
                                    ContactRepository.fetchContacts().onSuccess { fetched ->
                                        store.serverContacts = fetched
                                    }
                                    store.isSyncingServer = false
                                }
                            },
                            shape = CircleShape,
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                if (store.isSyncingServer) {
                                    CircularProgressIndicator(
                                        color = accent,
                                        strokeWidth = 2.dp,
                                        modifier = Modifier.size(12.dp)
                                    )
                                } else {
                                    Icon(Icons.Default.Refresh, contentDescription = null, tint = accent, modifier = Modifier.size(13.dp))
                                }
                                Text("Sync Server", color = accent, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            }
                        }

                        Surface(
                            onClick = { onOpenDestination(DashboardDestination.DIRECTORY) },
                            shape = CircleShape,
                            color = tint,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line)
                        ) {
                            Text(
                                text = "Server View",
                                color = accent,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                            )
                        }
                    }
                }

                // Search Input
                GavinSearchField(
                    value = store.dirQuery,
                    onValueChange = { store.dirQuery = it },
                    placeholder = "Search by name, role, building, or department…"
                )

                // Role Filter Chips
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        listOf("All", "Faculty", "Staff").forEach { f ->
                            val on = store.filter == f
                            Surface(
                                onClick = { store.filter = f },
                                shape = CircleShape,
                                color = if (on) accent else Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, if (on) accent else line)
                            ) {
                                Text(
                                    text = f,
                                    color = if (on) Color.White else ink,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 5.dp)
                                )
                            }
                        }
                    }
                    val total = store.filteredDirectoryPeople.size
                    Text(
                        text = if (total > 40) "Showing 40 of $total" else "$total people",
                        color = sub,
                        fontSize = 11.sp
                    )
                }

                val visible = store.filteredDirectoryPeople.take(40)
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(bottom = 12.dp)
                ) {
                    items(visible, key = { it.id }) { person ->
                        GavinPersonRow(
                            person = person,
                            onClick = {
                                store.contactId = person.id
                                store.sheet = GavinActiveSheet.CONTACT
                            },
                            onLocateOnMap = {
                                onLocateContactOnMap(store.contactForPerson(person))
                            }
                        )
                    }
                }
            }

            GavinPeopleSubView.HELP -> {
                val curOff = store.currentOffice
                if (curOff != null) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState()),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        TextButton(onClick = { store.office = null }) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = accent)
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Get help", color = accent, fontWeight = FontWeight.Bold)
                        }
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text(curOff.category.uppercase(), color = accent, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                                Text(curOff.name, color = ink, fontSize = 22.sp, fontFamily = GavinDisplayFontFamily, fontWeight = FontWeight.Black)
                                Text(curOff.goHereFor, color = sub, fontSize = 13.sp)

                                HorizontalDivider(color = LociBrandState.rule, modifier = Modifier.padding(vertical = 4.dp))

                                curOff.phone?.let { ph ->
                                    GavinDetailActionRow("Phone", ph) {
                                        try {
                                            context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$ph")))
                                        } catch (_: Exception) {}
                                    }
                                }
                                curOff.email?.let { em ->
                                    GavinDetailActionRow("Email", em) {
                                        try {
                                            context.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$em")))
                                        } catch (_: Exception) {}
                                    }
                                }
                                curOff.location?.let { loc ->
                                    GavinDetailActionRow("Location", "$loc · Locate on Map") {
                                        onOpenDestination(DashboardDestination.MAP)
                                    }
                                }
                                curOff.hours?.let { hrs ->
                                    GavinDetailActionRow("Hours", hrs, onClick = null)
                                }
                            }
                        }
                    }
                } else {
                    Text(
                        text = "Get help",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    GavinSearchField(
                        value = store.helpQuery,
                        onValueChange = { store.helpQuery = it },
                        placeholder = "Describe what you need help with…"
                    )
                    val offices = store.filteredHelpOffices
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        contentPadding = PaddingValues(bottom = 12.dp)
                    ) {
                        items(offices, key = { it.first.id }) { (off, showHead) ->
                            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                if (showHead) {
                                    Text(
                                        text = off.category.uppercase(),
                                        color = sub,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.ExtraBold,
                                        modifier = Modifier.padding(top = 6.dp, start = 4.dp)
                                    )
                                }
                                Surface(
                                    onClick = { store.office = off.id },
                                    shape = RoundedCornerShape(14.dp),
                                    color = Color.White,
                                    border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Row(
                                        modifier = Modifier.padding(14.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                                            Text(off.name, color = ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                            Text(off.goHereFor, color = sub, fontSize = 12.sp)
                                            off.location?.let { loc ->
                                                Text(loc, color = accent, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
                                            }
                                        }
                                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            GavinPeopleSubView.DEPTS -> {
                val curDept = store.dept
                if (curDept != null) {
                    val groups = store.currentDeptPeopleGrouped
                    val meta = store.deptMeta[curDept]
                    Column(modifier = Modifier.fillMaxSize()) {
                        TextButton(onClick = { store.dept = null }) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = accent)
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Departments", color = accent, fontWeight = FontWeight.Bold)
                        }
                        Text(
                            text = curDept,
                            color = ink,
                            fontSize = 20.sp,
                            fontFamily = GavinDisplayFontFamily,
                            fontWeight = FontWeight.Black,
                            modifier = Modifier.padding(bottom = 6.dp)
                        )
                        if (meta != null && meta.isNotEmpty()) {
                            Text(
                                text = meta.filter { it.isNotBlank() }.joinToString(" · "),
                                color = sub,
                                fontSize = 12.sp,
                                modifier = Modifier.padding(bottom = 8.dp)
                            )
                        }
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                            contentPadding = PaddingValues(bottom = 12.dp)
                        ) {
                            groups.forEach { (groupTitle, members, _) ->
                                item(key = "head-$groupTitle") {
                                    Text(
                                        text = groupTitle.uppercase(),
                                        color = sub,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.ExtraBold,
                                        modifier = Modifier.padding(top = 6.dp)
                                    )
                                }
                                items(members, key = { it.id }) { person ->
                                    GavinPersonRow(
                                        person = person,
                                        onClick = {
                                            store.contactId = person.id
                                            store.sheet = GavinActiveSheet.CONTACT
                                        },
                                        onLocateOnMap = {
                                            onLocateContactOnMap(store.contactForPerson(person))
                                        }
                                    )
                                }
                            }
                        }
                    }
                } else {
                    Text(
                        text = "Departments",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    GavinSearchField(
                        value = store.deptQuery,
                        onValueChange = { store.deptQuery = it },
                        placeholder = "Search departments…"
                    )
                    val depts = store.filteredDepartments.take(40)
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        contentPadding = PaddingValues(bottom = 12.dp)
                    ) {
                        items(depts, key = { it.name }) { d ->
                            Surface(
                                onClick = { store.dept = d.name },
                                shape = RoundedCornerShape(14.dp),
                                color = Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier.padding(14.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(d.name, color = ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                        Text(d.countText, color = sub, fontSize = 12.sp)
                                    }
                                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub)
                                }
                            }
                        }
                    }
                }
            }

            GavinPeopleSubView.ORGS -> {
                val curOrg = store.currentOrg
                if (curOrg != null) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState()),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        TextButton(onClick = { store.org = null }) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = accent)
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Student organizations", color = accent, fontWeight = FontWeight.Bold)
                        }
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text(curOrg.cat.uppercase(), color = accent, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                                Text(curOrg.name, color = ink, fontSize = 22.sp, fontFamily = GavinDisplayFontFamily, fontWeight = FontWeight.Black)
                                Text(curOrg.desc, color = sub, fontSize = 13.sp)
                                if (curOrg.email.isNotBlank()) {
                                    GavinDetailActionRow("Email", curOrg.email) {
                                        try {
                                            context.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:${curOrg.email}")))
                                        } catch (_: Exception) {}
                                    }
                                }
                                if (curOrg.site.isNotBlank()) {
                                    GavinDetailActionRow("Website", curOrg.site) {
                                        try {
                                            context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(curOrg.site)))
                                        } catch (_: Exception) {}
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text(
                        text = "Student organizations",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    GavinSearchField(
                        value = store.orgQuery,
                        onValueChange = { store.orgQuery = it },
                        placeholder = "Search clubs and organizations…"
                    )
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        (listOf("All") + store.orgCatNames).forEach { cat ->
                            val on = store.orgCat == cat
                            Surface(
                                onClick = { store.orgCat = cat },
                                shape = CircleShape,
                                color = if (on) accent else Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, if (on) accent else line)
                            ) {
                                Text(
                                    text = cat,
                                    color = if (on) Color.White else ink,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 11.dp, vertical = 5.dp)
                                )
                            }
                        }
                    }
                    val visibleOrgs = store.filteredOrgs.take(40)
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        contentPadding = PaddingValues(bottom = 12.dp)
                    ) {
                        items(visibleOrgs, key = { it.i }) { o ->
                            Surface(
                                onClick = { store.org = o.i },
                                shape = RoundedCornerShape(14.dp),
                                color = Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier.padding(14.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                        Text(o.name, color = ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                        Text(o.cat, color = sub, fontSize = 11.sp)
                                    }
                                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ============================================================================
// 3. MAP TAB (Live Interactive Map + Gavin Campus Diagram Switcher)
// ============================================================================
@Composable
private fun GavinMapTab(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onLocateContactOnMap: (Contact) -> Unit
) {
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent

    Column(modifier = Modifier.fillMaxSize()) {
        // Top Bar: Mode Switcher + Full Screen Button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color.White)
                    .border(1.dp, line, RoundedCornerShape(12.dp))
                    .padding(3.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                GavinMapViewMode.entries.forEach { mode ->
                    val active = store.mapMode == mode
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(9.dp))
                            .background(if (active) accent else Color.Transparent)
                            .clickable { store.mapMode = mode }
                            .padding(vertical = 7.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = mode.label,
                            color = if (active) Color.White else ink,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            maxLines = 1
                        )
                    }
                }
            }

            if (store.mapMode == GavinMapViewMode.INTERACTIVE) {
                Surface(
                    onClick = { onOpenDestination(DashboardDestination.MAP) },
                    shape = RoundedCornerShape(10.dp),
                    color = Color.White,
                    border = androidx.compose.foundation.BorderStroke(1.dp, line)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(Icons.Default.Fullscreen, contentDescription = "Full Screen", tint = accent, modifier = Modifier.size(16.dp))
                        Text("Full", color = accent, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        if (store.mapMode == GavinMapViewMode.INTERACTIVE) {
            Box(modifier = Modifier.fillMaxSize()) {
                MapScreen(
                    focusedContact = null,
                    onClose = { store.go(GavinTab.HOME) }
                )
            }
        } else {
            // Gavin Campus Diagram View
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 14.dp, vertical = 6.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    listOf("All", "Academic", "Services", "Housing", "Athletics").forEach { lyr ->
                        val on = store.layer == lyr
                        Surface(
                            onClick = { store.layer = lyr },
                            shape = CircleShape,
                            color = if (on) accent else Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, if (on) accent else line)
                        ) {
                            Text(
                                text = lyr,
                                color = if (on) Color.White else ink,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }
                    }
                }

                // Interactive SVG-like Campus Diagram Canvas + Building Pins
                BoxWithConstraints(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(270.dp)
                        .clip(RoundedCornerShape(18.dp))
                        .background(Color(0xFFE7EFE8))
                        .border(1.dp, line, RoundedCornerShape(18.dp))
                ) {
                    val canvasW = maxWidth
                    val canvasH = maxHeight

                    Canvas(modifier = Modifier.fillMaxSize()) {
                        // Portage Lake / Waterway at top
                        val waterPath = Path().apply {
                            moveTo(0f, 0f)
                            lineTo(size.width, 0f)
                            lineTo(size.width, size.height * 0.22f)
                            cubicTo(
                                size.width * 0.72f, size.height * 0.16f,
                                size.width * 0.35f, size.height * 0.25f,
                                0f, size.height * 0.19f
                            )
                            close()
                        }
                        drawPath(waterPath, color = Color(0xFFBBD7EC))

                        // US-41 / Townsend Drive curve
                        val roadPath = Path().apply {
                            moveTo(0f, size.height * 0.45f)
                            cubicTo(
                                size.width * 0.35f, size.height * 0.41f,
                                size.width * 0.65f, size.height * 0.56f,
                                size.width, size.height * 0.74f
                            )
                        }
                        drawPath(
                            path = roadPath,
                            color = Color(0xFFD6D2C6),
                            style = Stroke(width = 24f, cap = StrokeCap.Round)
                        )
                    }

                    GavinStore.mapBuildings.forEach { b ->
                        val dim = store.layer != "All" && b.layer != store.layer
                        val sel = store.building == b.id
                        val leftFrac = ((b.x - b.w / 2f) / 1080f).coerceIn(0.01f, 0.88f)
                        val topFrac = ((b.y - b.h / 2f) / 760f).coerceIn(0.05f, 0.86f)

                        Surface(
                            onClick = {
                                store.building = b.id
                                store.floor = "1F"
                            },
                            shape = RoundedCornerShape(7.dp),
                            color = b.bgColor.copy(alpha = if (dim) 0.28f else 0.94f),
                            border = if (sel) androidx.compose.foundation.BorderStroke(2.dp, Color.White) else null,
                            shadowElevation = if (sel) 6.dp else 1.dp,
                            modifier = Modifier
                                .offset(
                                    x = canvasW * leftFrac,
                                    y = canvasH * topFrac
                                )
                        ) {
                            Text(
                                text = b.short,
                                color = Color.White,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.ExtraBold,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 4.dp)
                            )
                        }
                    }
                }

                // Selected Building Inspector Card
                store.selectedMapBuilding?.let { selBld ->
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = Color.White,
                        border = androidx.compose.foundation.BorderStroke(1.dp, line),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.Top
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(selBld.layer.uppercase(), color = accent, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                                    Text(selBld.name, color = ink, fontSize = 18.sp, fontFamily = GavinDisplayFontFamily, fontWeight = FontWeight.Black)
                                    Text(selBld.inside, color = sub, fontSize = 12.sp)
                                }
                                IconButton(onClick = { store.building = null }) {
                                    Icon(Icons.Default.Close, contentDescription = "Close", tint = sub)
                                }
                            }

                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Text("Floor:", color = sub, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                listOf("1F", "2F", "3F").forEach { fl ->
                                    val on = store.floor == fl
                                    Surface(
                                        onClick = { store.floor = fl },
                                        shape = CircleShape,
                                        color = if (on) accent else tint,
                                        border = androidx.compose.foundation.BorderStroke(1.dp, if (on) accent else line)
                                    ) {
                                        Text(
                                            text = fl,
                                            color = if (on) Color.White else ink,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
                                        )
                                    }
                                }
                            }

                            ModernButton(
                                text = "Open in Live Interactive Map & Blueprint",
                                onClick = {
                                    store.mapMode = GavinMapViewMode.INTERACTIVE
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

// ============================================================================
// 4. PLANNER TAB (Tasks, My Classes, Periods 1–8 with Friday Schedule Toggle)
// ============================================================================
@Composable
private fun GavinPlannerTab(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit
) {
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 14.dp, vertical = 10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Segmented Control: Tasks | My classes | Periods
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Color.White)
                .border(1.dp, line, RoundedCornerShape(12.dp))
                .padding(3.dp),
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            GavinPlanMode.entries.forEach { mode ->
                val active = store.planMode == mode
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(9.dp))
                        .background(if (active) accent else Color.Transparent)
                        .clickable { store.planMode = mode }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = mode.label,
                        color = if (active) Color.White else ink,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        when (store.planMode) {
            GavinPlanMode.TASKS -> {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Tasks",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        Surface(
                            onClick = { onOpenDestination(DashboardDestination.HOMEWORK_PLANNER) },
                            shape = CircleShape,
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line)
                        ) {
                            Text(
                                text = "Reorder / Edit",
                                color = accent,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }
                        Surface(
                            onClick = { store.sheet = GavinActiveSheet.ADD_TASK },
                            shape = CircleShape,
                            color = accent
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Icon(Icons.Default.Add, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                                Text("Add", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }

                val openTasks = store.tasks.filter { !it.done }
                val doneTasks = store.tasks.filter { it.done }

                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(bottom = 14.dp)
                ) {
                    if (openTasks.isEmpty() && doneTasks.isEmpty()) {
                        item {
                            Surface(
                                shape = RoundedCornerShape(16.dp),
                                color = Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Column(
                                    modifier = Modifier.padding(24.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Text("No tasks yet", color = ink, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                                    Text("Add an assignment, exam, project, or reading.", color = sub, fontSize = 12.sp)
                                }
                            }
                        }
                    }

                    items(openTasks, key = { it.id }) { task ->
                        GavinTaskCardRow(
                            task = task,
                            onToggle = { store.toggleTask(task.id) },
                            onDelete = { store.deleteTask(task.id) }
                        )
                    }

                    if (doneTasks.isNotEmpty()) {
                        item {
                            Text(
                                text = "COMPLETED (${doneTasks.size})",
                                color = sub,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.ExtraBold,
                                modifier = Modifier.padding(top = 8.dp)
                            )
                        }
                        items(doneTasks, key = { it.id }) { task ->
                            GavinTaskCardRow(
                                task = task,
                                onToggle = { store.toggleTask(task.id) },
                                onDelete = { store.deleteTask(task.id) }
                            )
                        }
                    }
                }
            }

            GavinPlanMode.TIMES -> {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "My classes",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    Surface(
                        onClick = { store.sheet = GavinActiveSheet.ADD_CLASS },
                        shape = CircleShape,
                        color = accent
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(Icons.Default.Add, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                            Text("Add class", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                val sorted = store.sortedClasses
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(bottom = 14.dp)
                ) {
                    items(sorted, key = { it.item.id }) { entry ->
                        Surface(
                            shape = RoundedCornerShape(14.dp),
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier.padding(14.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                                    Text(entry.code, color = ink, fontWeight = FontWeight.ExtraBold, fontSize = 15.sp)
                                    Text(entry.name, color = sub, fontSize = 12.sp)
                                    Text(entry.whenText, color = accent, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                                }
                                IconButton(onClick = { store.removeClass(entry.item.id) }) {
                                    Icon(Icons.Default.DeleteOutline, contentDescription = "Remove", tint = sub)
                                }
                            }
                        }
                    }
                }
            }

            GavinPlanMode.PERIODS -> {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (store.fridayScheduleEnabled) "Friday Schedule" else "Regular Schedule",
                        color = ink,
                        fontSize = 22.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black
                    )
                    Surface(
                        onClick = { onOpenDestination(DashboardDestination.SCHEDULE) },
                        shape = CircleShape,
                        color = Color.White,
                        border = androidx.compose.foundation.BorderStroke(1.dp, line)
                    ) {
                        Text(
                            text = "Full View",
                            color = accent,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                        )
                    }
                }

                // Friday Schedule Toggle Card
                Surface(
                    shape = RoundedCornerShape(14.dp),
                    color = Color.White,
                    border = androidx.compose.foundation.BorderStroke(1.dp, line),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("Friday Schedule", color = ink, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                            Text("Adjust Period 1 bell times for Friday", color = sub, fontSize = 12.sp)
                        }
                        Switch(
                            checked = store.fridayScheduleEnabled,
                            onCheckedChange = {
                                store.fridayScheduleEnabled = it
                                store.persistState()
                            },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = accent
                            )
                        )
                    }
                }

                val times = if (store.fridayScheduleEnabled) GavinStore.fridayPeriodTimes else GavinStore.regularPeriodTimes
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(bottom = 14.dp)
                ) {
                    items(8) { idx ->
                        Surface(
                            shape = RoundedCornerShape(14.dp),
                            color = Color.White,
                            border = androidx.compose.foundation.BorderStroke(1.dp, line),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp, vertical = 12.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(34.dp)
                                            .clip(CircleShape)
                                            .background(tint),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = "${idx + 1}",
                                            color = accent,
                                            fontWeight = FontWeight.ExtraBold,
                                            fontSize = 14.sp
                                        )
                                    }
                                    Text(
                                        text = "Period ${idx + 1}",
                                        color = ink,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 14.sp
                                    )
                                }
                                Text(
                                    text = times[idx],
                                    color = ink,
                                    fontFamily = FontFamily.Monospace,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 15.sp
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// ============================================================================
// 5. MORE TAB (All Features, Theme Picker, Widgets, Admin Settings, Sign Out)
// ============================================================================
@Composable
private fun GavinMoreTab(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onOpenAdminSettings: () -> Unit,
    onSignOut: () -> Unit
) {
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint
    val accent = LociBrandState.accent

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            text = "More",
            color = ink,
            fontSize = 24.sp,
            fontFamily = GavinDisplayFontFamily,
            fontWeight = FontWeight.Black
        )

        // Campus Features & Tools
        GavinCardSection(title = "Campus features & tools") {
            val items = listOf(
                Triple("Ask LociStoa Chatbot", "AI assistant for buildings, skywalks, CCLC & advising", Icons.Default.SmartToy) to {
                    onOpenDestination(DashboardDestination.CHATBOT)
                },
                Triple("Fall Career Fair", "Search attending companies and SDC booth numbers", Icons.Default.WorkOutline) to {
                    onOpenDestination(DashboardDestination.CAREER_FAIR)
                },
                Triple("Campus Nomenclature", "MTU building nicknames, acronyms & campus lingo", Icons.Default.Book) to {
                    onOpenDestination(DashboardDestination.NOMENCLATURE)
                },
                Triple("Course Period Schedule", "Regular & Friday 8-period bell schedule", Icons.Default.Schedule) to {
                    onOpenDestination(DashboardDestination.SCHEDULE)
                },
                Triple("TaskFlow Planner", "Full task reorder & assignment manager", Icons.Default.CalendarMonth) to {
                    onOpenDestination(DashboardDestination.HOMEWORK_PLANNER)
                },
                Triple("Common Links", "MyMichiganTech, Canvas, Banweb & Academic Calendar", Icons.Default.Link) to {
                    onOpenDestination(DashboardDestination.COMMON_LINKS)
                },
                Triple("Emergency Numbers", "911, Public Safety, 988 & Counseling", Icons.Default.Phone) to {
                    store.sheet = GavinActiveSheet.EMERGENCY
                }
            )
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                items.forEach { (info, action) ->
                    val (label, desc, icon) = info
                    Surface(
                        onClick = action,
                        shape = RoundedCornerShape(12.dp),
                        color = tint.copy(alpha = 0.45f),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(36.dp)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(Color.White),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(icon, contentDescription = null, tint = accent, modifier = Modifier.size(18.dp))
                            }
                            Column(modifier = Modifier.weight(1f)) {
                                Text(label, color = ink, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text(desc, color = sub, fontSize = 11.sp)
                            }
                            Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = sub)
                        }
                    }
                }
            }
        }

        // Theme Picker (Purple, Blue, Green, Copper)
        GavinCardSection(title = "Theme") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                LociTheme.entries.forEach { th ->
                    val isSelected = LociBrandState.theme == th && LociBrandState.customAccent == null
                    Surface(
                        onClick = {
                            LociBrandState.selectThemePreset(th)
                            store.persistState()
                        },
                        shape = RoundedCornerShape(12.dp),
                        color = if (isSelected) tint else Color.White,
                        border = androidx.compose.foundation.BorderStroke(
                            width = if (isSelected) 2.dp else 1.dp,
                            color = if (isSelected) th.swatch else line
                        ),
                        modifier = Modifier.weight(1f)
                    ) {
                        Column(
                            modifier = Modifier.padding(vertical = 10.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(24.dp)
                                    .clip(CircleShape)
                                    .background(th.swatch),
                                contentAlignment = Alignment.Center
                            ) {
                                if (isSelected) {
                                    Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                                }
                            }
                            Text(
                                text = th.label,
                                color = ink,
                                fontSize = 11.sp,
                                fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.SemiBold
                            )
                        }
                    }
                }
            }
        }

        // Home Screen Widgets
        GavinCardSection(title = "Home screen widgets") {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                GavinStore.widgetDefinitions.forEach { (key, label, desc, _) ->
                    val enabled = store.isWidgetEnabled(key)
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(label, color = ink, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            Text(desc, color = sub, fontSize = 11.sp)
                        }
                        Switch(
                            checked = enabled,
                            onCheckedChange = { store.toggleWidget(key) },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = accent
                            )
                        )
                    }
                }
            }
        }

        // IT Administrator Settings & Sign Out
        GavinCardSection(title = "Administration & session") {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                GavinSecondaryButton(
                    text = "IT Administrator Settings (PIN: 1234)",
                    onClick = onOpenAdminSettings
                )
                ModernButton(
                    text = "Sign Out",
                    onClick = onSignOut,
                    containerColor = ink
                )
            }
        }
    }
}

// ============================================================================
// SHARED COMPONENTS & MODALS
// ============================================================================
@Composable
private fun GavinCardSection(
    title: String,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
    content: @Composable () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = Color.White,
        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    color = LociBrandState.ink,
                    fontSize = 15.sp,
                    fontFamily = GavinDisplayFontFamily,
                    fontWeight = FontWeight.ExtraBold
                )
                if (actionLabel != null && onAction != null) {
                    Text(
                        text = actionLabel,
                        color = LociBrandState.accent,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.clickable(onClick = onAction)
                    )
                }
            }
            content()
        }
    }
}

@Composable
private fun GavinSearchField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        placeholder = { Text(placeholder, color = LociBrandState.sub, fontSize = 13.sp) },
        leadingIcon = {
            Icon(Icons.Default.Search, contentDescription = null, tint = LociBrandState.sub, modifier = Modifier.size(18.dp))
        },
        trailingIcon = {
            if (value.isNotEmpty()) {
                IconButton(onClick = { onValueChange("") }) {
                    Icon(Icons.Default.Close, contentDescription = "Clear", tint = LociBrandState.sub, modifier = Modifier.size(16.dp))
                }
            }
        },
        singleLine = true,
        shape = RoundedCornerShape(12.dp),
        colors = OutlinedTextFieldDefaults.colors(
            focusedContainerColor = Color.White,
            unfocusedContainerColor = Color.White,
            focusedBorderColor = LociBrandState.accent,
            unfocusedBorderColor = LociBrandState.line,
            focusedTextColor = LociBrandState.ink,
            unfocusedTextColor = LociBrandState.ink
        ),
        modifier = Modifier.fillMaxWidth()
    )
}

@Composable
private fun GavinPersonRow(
    person: GavinPerson,
    onClick: () -> Unit,
    onLocateOnMap: () -> Unit
) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(14.dp),
        color = Color.White,
        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(LociBrandState.tint),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = person.initials,
                    color = LociBrandState.accent,
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 13.sp
                )
            }
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(person.name, color = LociBrandState.ink, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Text(person.role, color = LociBrandState.sub, fontSize = 12.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Text("${person.dept} · ${person.office}", color = LociBrandState.sub, fontSize = 11.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
            if (person.office.isNotBlank() && person.office != "Not listed") {
                Surface(
                    onClick = onLocateOnMap,
                    shape = CircleShape,
                    color = LociBrandState.tint,
                    border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(3.dp)
                    ) {
                        Icon(Icons.Default.LocationOn, contentDescription = null, tint = LociBrandState.accent, modifier = Modifier.size(12.dp))
                        Text("Map", color = LociBrandState.accent, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
private fun GavinTaskCardRow(
    task: com.locistoa.app.data.GavinTaskItem,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        onClick = onToggle,
        shape = RoundedCornerShape(14.dp),
        color = Color.White,
        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Icon(
                imageVector = if (task.done) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
                contentDescription = null,
                tint = if (task.done) LociBrandState.accent else LociBrandState.check,
                modifier = Modifier.size(22.dp)
            )
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    text = "${task.type} · ${task.course}",
                    color = if (task.done) LociBrandState.sub else LociBrandState.ink,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    textDecoration = if (task.done) TextDecoration.LineThrough else TextDecoration.None
                )
                if (task.description.isNotBlank()) {
                    Text(
                        text = task.description,
                        color = LociBrandState.sub,
                        fontSize = 12.sp
                    )
                }
                Text(
                    text = "Due: ${task.due}",
                    color = LociBrandState.accent,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
            IconButton(onClick = onDelete) {
                Icon(Icons.Default.DeleteOutline, contentDescription = "Delete", tint = LociBrandState.sub)
            }
        }
    }
}

@Composable
private fun GavinDetailActionRow(
    label: String,
    value: String,
    onClick: (() -> Unit)?
) {
    Surface(
        onClick = { onClick?.invoke() },
        enabled = onClick != null,
        shape = RoundedCornerShape(10.dp),
        color = LociBrandState.tint.copy(alpha = 0.45f),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(label.uppercase(), color = LociBrandState.sub, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                Text(value, color = LociBrandState.ink, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            }
            if (onClick != null) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = LociBrandState.accent)
            }
        }
    }
}

// ============================================================================
// SHEET 1: EMERGENCY NUMBERS
// ============================================================================
@Composable
private fun GavinEmergencySheetContent(onClose: () -> Unit) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 28.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Emergency numbers",
                color = LociBrandState.ink,
                fontSize = 20.sp,
                fontFamily = GavinDisplayFontFamily,
                fontWeight = FontWeight.Black
            )
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close")
            }
        }
        Text(
            text = "Tap any number to place a call.",
            color = LociBrandState.sub,
            fontSize = 13.sp
        )
        GavinStore.emergencyNumbers.forEach { em ->
            Surface(
                onClick = {
                    try {
                        context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:${em.number}")))
                    } catch (_: Exception) {}
                },
                shape = RoundedCornerShape(14.dp),
                color = if (em.primary) Color(0xFFFDECEC) else LociBrandState.tint.copy(alpha = 0.5f),
                border = androidx.compose.foundation.BorderStroke(
                    1.dp,
                    if (em.primary) Color(0xFFF5B5B5) else LociBrandState.line
                ),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = em.chip,
                            color = if (em.primary) Color(0xFFB42318) else LociBrandState.ink,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 15.sp
                        )
                        Text(em.label, color = LociBrandState.sub, fontSize = 12.sp)
                    }
                    Text(
                        text = em.number,
                        color = if (em.primary) Color(0xFFB42318) else LociBrandState.accent,
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 14.sp
                    )
                }
            }
        }
    }
}

// ============================================================================
// SHEET 2: CONTACT DETAIL SHEET
// ============================================================================
@Composable
private fun GavinContactSheetContent(
    store: GavinStore,
    person: GavinPerson,
    onLocateOnInteractiveMap: () -> Unit,
    onClose: () -> Unit
) {
    val context = LocalContext.current
    val isFav = store.favs[person.email] == true

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 28.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(CircleShape)
                    .background(LociBrandState.tint),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = person.initials,
                    color = LociBrandState.accent,
                    fontWeight = FontWeight.Black,
                    fontSize = 18.sp
                )
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(person.name, color = LociBrandState.ink, fontWeight = FontWeight.ExtraBold, fontSize = 18.sp)
                Text(person.role, color = LociBrandState.sub, fontSize = 13.sp)
            }
            IconButton(onClick = { store.toggleFav(person.email) }) {
                Icon(
                    imageVector = if (isFav) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
                    contentDescription = "Save",
                    tint = LociBrandState.accent
                )
            }
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close", tint = LociBrandState.sub)
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Surface(
                onClick = {
                    try {
                        context.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:${person.email}")))
                    } catch (_: Exception) {}
                },
                shape = RoundedCornerShape(12.dp),
                color = LociBrandState.tint,
                modifier = Modifier.weight(1f)
            ) {
                Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Icon(Icons.Default.Email, contentDescription = null, tint = LociBrandState.accent, modifier = Modifier.size(18.dp))
                    Text("Email", color = LociBrandState.ink, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    Text(person.email, color = LociBrandState.sub, fontSize = 11.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }
            }

            Surface(
                onClick = {
                    try {
                        context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:${person.phone}")))
                    } catch (_: Exception) {}
                },
                shape = RoundedCornerShape(12.dp),
                color = LociBrandState.tint,
                modifier = Modifier.weight(1f)
            ) {
                Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Icon(Icons.Default.Phone, contentDescription = null, tint = LociBrandState.accent, modifier = Modifier.size(18.dp))
                    Text("Call", color = LociBrandState.ink, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    Text(person.phone, color = LociBrandState.sub, fontSize = 11.sp, maxLines = 1)
                }
            }
        }

        GavinDetailActionRow(
            label = "Office",
            value = "${person.office} · Locate on Indoor Blueprint",
            onClick = onLocateOnInteractiveMap
        )

        GavinDetailActionRow(
            label = "Department",
            value = person.dept,
            onClick = {
                store.go(
                    targetTab = GavinTab.PEOPLE,
                    subView = GavinPeopleSubView.DEPTS,
                    resetPeopleSelection = true,
                    targetDept = person.dept
                )
            }
        )
    }
}

// ============================================================================
// SHEET 3: ADD TASK SHEET
// ============================================================================
@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun GavinAddTaskSheetContent(
    store: GavinStore,
    onClose: () -> Unit
) {
    val types = listOf("Assignment", "Exam", "Project", "Reading", "Other")
    val courses = store.courseOptionsForTask

    var selectedType by remember { mutableStateOf("Assignment") }
    var selectedCourse by remember { mutableStateOf(courses.firstOrNull() ?: "Other") }
    var description by remember { mutableStateOf("") }
    var dueDateMillis by remember { mutableStateOf(System.currentTimeMillis()) }
    var showDatePicker by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 28.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Add a task",
                color = LociBrandState.ink,
                fontSize = 20.sp,
                fontFamily = GavinDisplayFontFamily,
                fontWeight = FontWeight.Black
            )
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close")
            }
        }

        Text("TYPE OF ASSIGNMENT", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            types.forEach { t ->
                val on = selectedType == t
                Surface(
                    onClick = { selectedType = t },
                    shape = CircleShape,
                    color = if (on) LociBrandState.accent else LociBrandState.tint,
                    border = androidx.compose.foundation.BorderStroke(1.dp, if (on) LociBrandState.accent else LociBrandState.line)
                ) {
                    Text(
                        text = t,
                        color = if (on) Color.White else LociBrandState.ink,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                    )
                }
            }
        }

        Text("COURSE", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            courses.forEach { c ->
                val on = selectedCourse == c
                Surface(
                    onClick = { selectedCourse = c },
                    shape = CircleShape,
                    color = if (on) LociBrandState.accent else LociBrandState.tint,
                    border = androidx.compose.foundation.BorderStroke(1.dp, if (on) LociBrandState.accent else LociBrandState.line)
                ) {
                    Text(
                        text = c,
                        color = if (on) Color.White else LociBrandState.ink,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                    )
                }
            }
        }

        OutlinedTextField(
            value = description,
            onValueChange = { description = it },
            label = { Text("Description (Optional)") },
            singleLine = true,
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth()
        )

        GavinDetailActionRow(
            label = "Due Date",
            value = GavinStore.formatDueDate(dueDateMillis),
            onClick = { showDatePicker = true }
        )

        ModernButton(
            text = "Save task",
            onClick = {
                store.addTask(
                    type = selectedType,
                    course = selectedCourse,
                    description = description,
                    dueDateMillis = dueDateMillis
                )
            }
        )
    }

    if (showDatePicker) {
        val pickerState = rememberDatePickerState(initialSelectedDateMillis = dueDateMillis)
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(
                    onClick = {
                        pickerState.selectedDateMillis?.let { dueDateMillis = it }
                        showDatePicker = false
                    }
                ) {
                    Text("OK")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) {
                    Text("Cancel")
                }
            }
        ) {
            DatePicker(state = pickerState)
        }
    }
}

// ============================================================================
// SHEET 4: ADD CLASS SHEET
// ============================================================================
@Composable
private fun GavinAddClassSheetContent(
    store: GavinStore,
    onClose: () -> Unit
) {
    var subj by remember { mutableStateOf("CS") }
    var num by remember { mutableStateOf("1121") }
    val selectedDays = remember { mutableStateMapOf("M" to true, "W" to true, "F" to true) }
    var start by remember { mutableStateOf("10:00") }
    var end by remember { mutableStateOf("10:50") }
    var loc by remember { mutableStateOf("Rekhi 214") }
    var err by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 28.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Add a class",
                color = LociBrandState.ink,
                fontSize = 20.sp,
                fontFamily = GavinDisplayFontFamily,
                fontWeight = FontWeight.Black
            )
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close")
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = subj,
                onValueChange = { subj = it.uppercase() },
                label = { Text("Subject (e.g. CS)") },
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
            OutlinedTextField(
                value = num,
                onValueChange = { num = it },
                label = { Text("Course # (e.g. 1121)") },
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
        }

        Text("DAYS", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            GavinStore.daysInfo.forEach { (code, label) ->
                val on = selectedDays[code] == true
                Surface(
                    onClick = { selectedDays[code] = !on },
                    shape = RoundedCornerShape(10.dp),
                    color = if (on) LociBrandState.accent else LociBrandState.tint,
                    modifier = Modifier.weight(1f)
                ) {
                    Box(
                        modifier = Modifier.padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = label,
                            color = if (on) Color.White else LociBrandState.ink,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = start,
                onValueChange = { start = it },
                label = { Text("Start (HH:MM)") },
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
            OutlinedTextField(
                value = end,
                onValueChange = { end = it },
                label = { Text("End (HH:MM)") },
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
        }

        OutlinedTextField(
            value = loc,
            onValueChange = { loc = it },
            label = { Text("Building & room (optional)") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )

        if (err.isNotBlank()) {
            Text(err, color = Color(0xFFB42318), fontSize = 12.sp, fontWeight = FontWeight.Bold)
        }

        ModernButton(
            text = "Save class",
            onClick = {
                val daysStr = GavinStore.daysInfo.map { it.first }.filter { selectedDays[it] == true }.joinToString("")
                if (subj.isBlank() || num.isBlank() || daysStr.isEmpty()) {
                    err = "Enter subject, course number, and at least one day."
                } else {
                    store.addClass(subj.trim(), num.trim(), daysStr, start.trim(), end.trim(), loc.trim())
                }
            }
        )
    }
}

// ============================================================================
// SHEET 5: UNIVERSAL SEARCH MODAL
// ============================================================================
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun GavinSearchModalContent(
    store: GavinStore,
    onOpenDestination: (DashboardDestination) -> Unit,
    onClose: () -> Unit
) {
    val q = store.query.trim().lowercase()

    val lingoHits = remember(q) {
        if (q.isEmpty()) emptyList()
        else GavinStore.campusLingo.filter {
            "${it.term} ${it.meaning} ${it.details}".lowercase().contains(q)
        }
    }
    val officeHits = remember(q) {
        if (q.isEmpty()) emptyList()
        else store.offices.filter { it.hay.contains(q) }.take(4)
    }
    val peopleHits = remember(q) {
        if (q.isEmpty()) emptyList()
        else store.people.filter { it.hay.contains(q) }.take(5)
    }
    val orgHits = remember(q) {
        if (q.isEmpty()) emptyList()
        else store.orgs.filter { it.hay.contains(q) }.take(4)
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 420.dp, max = 680.dp)
            .padding(horizontal = 18.dp)
            .padding(bottom = 24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(modifier = Modifier.weight(1f)) {
                GavinSearchField(
                    value = store.query,
                    onValueChange = { store.query = it },
                    placeholder = "Search people, offices, clubs, lingo…"
                )
            }
            TextButton(onClick = onClose) {
                Text("Done", color = LociBrandState.accent, fontWeight = FontWeight.Bold)
            }
        }

        if (q.isEmpty()) {
            Text("TRY SEARCHING FOR", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                listOf("tutoring", "Wads", "MUB", "career fair", "advising", "robotics", "skywalk", "Smith").forEach { sample ->
                    Surface(
                        onClick = { store.query = sample },
                        shape = CircleShape,
                        color = LociBrandState.tint,
                        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                    ) {
                        Text(
                            text = sample,
                            color = LociBrandState.ink,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                        )
                    }
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                if (lingoHits.isNotEmpty()) {
                    item {
                        Text("CAMPUS LINGO", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    items(lingoHits, key = { it.term }) { l ->
                        GavinDetailActionRow(
                            label = "“${l.term}” means",
                            value = "${l.meaning} · Tap to view on map"
                        ) {
                            store.mapMode = GavinMapViewMode.DIAGRAM
                            store.go(GavinTab.MAP, targetBuilding = l.buildingId, targetFloor = "1F")
                        }
                    }
                }

                if (officeHits.isNotEmpty()) {
                    item {
                        Text("OFFICES & SERVICES", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    items(officeHits, key = { it.id }) { o ->
                        GavinDetailActionRow(
                            label = o.name,
                            value = o.goHereFor
                        ) {
                            store.go(GavinTab.PEOPLE, subView = GavinPeopleSubView.HELP, resetPeopleSelection = true, targetOffice = o.id)
                        }
                    }
                }

                if (peopleHits.isNotEmpty()) {
                    item {
                        Text("PEOPLE", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    items(peopleHits, key = { it.id }) { p ->
                        GavinDetailActionRow(
                            label = p.name,
                            value = "${p.role} · ${p.dept}"
                        ) {
                            store.contactId = p.id
                            store.sheet = GavinActiveSheet.CONTACT
                        }
                    }
                }

                if (orgHits.isNotEmpty()) {
                    item {
                        Text("STUDENT ORGANIZATIONS", color = LociBrandState.sub, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    items(orgHits, key = { it.i }) { o ->
                        GavinDetailActionRow(
                            label = o.name,
                            value = o.cat
                        ) {
                            store.go(GavinTab.PEOPLE, subView = GavinPeopleSubView.ORGS, resetPeopleSelection = true, targetOrg = o.i)
                        }
                    }
                }
            }
        }
    }
}
