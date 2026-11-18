package com.locistoa.app.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuAnchorType
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
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
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.locistoa.app.data.Contact
import com.locistoa.app.data.ContactRepository
import com.locistoa.app.data.ToDoItem
import com.locistoa.app.data.ToDoRepository
import com.locistoa.app.ui.theme.LociBrandState
import com.locistoa.app.ui.theme.ModernButton
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

/**
 * Matches `CommonLinksView.swift`
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CommonLinksScreen(onClose: () -> Unit) {
    val context = LocalContext.current
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    fun openUrl(url: String) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            context.startActivity(intent)
        } catch (_: Exception) {
        }
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = { Text("Common Links", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(24.dp)
                .padding(top = 12.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            ModernButton(
                text = "MyMichiganTech",
                onClick = { openUrl("https://mymichigantech.mtu.edu/") }
            )
            ModernButton(
                text = "Canvas",
                onClick = { openUrl("https://mtu.instructure.com/") }
            )
            ModernButton(
                text = "Banweb",
                onClick = { openUrl("https://www.banweb.mtu.edu/") }
            )
            ModernButton(
                text = "Academic Calendar",
                onClick = { openUrl("https://www.mtu.edu/registrar/students/calendars/") }
            )
        }
    }
}

/**
 * Matches `ScheduleView.swift`
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScheduleScreen(onClose: () -> Unit) {
    var fridaySched by remember { mutableStateOf(false) }
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    val regularTimes = listOf(
        "08:30 - 09:18",
        "09:22 - 10:08",
        "10:13 - 11:07",
        "11:12 - 11:58",
        "12:03 - 12:49",
        "12:54 - 01:40",
        "01:45 - 02:31",
        "02:36 - 03:22"
    )
    val fridayTimes = listOf(
        "08:30 - 09:17",
        "09:22 - 10:08",
        "10:13 - 11:07",
        "11:12 - 11:58",
        "12:03 - 12:49",
        "12:54 - 01:40",
        "01:45 - 02:31",
        "02:36 - 03:22"
    )

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = if (fridaySched) "Friday Schedule" else "Regular Schedule",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = Color.White.copy(alpha = 0.65f),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Friday Schedule",
                        fontWeight = FontWeight.Bold,
                        fontSize = 17.sp,
                        color = Color(0xFF1A1A2E)
                    )
                    Switch(
                        checked = fridaySched,
                        onCheckedChange = { fridaySched = it },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = Color.White,
                            checkedTrackColor = lociAccent
                        )
                    )
                }
            }

            for (index in 0 until 8) {
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = Color.White,
                    shadowElevation = 2.dp,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(lociAccent.copy(alpha = 0.2f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "${index + 1}",
                                fontWeight = FontWeight.Bold,
                                fontSize = 17.sp,
                                color = lociAccent
                            )
                        }

                        Text(
                            text = if (fridaySched) fridayTimes[index] else regularTimes[index],
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Medium,
                            fontSize = 19.sp,
                            color = Color(0xFF1A1A2E)
                        )
                    }
                }
            }
        }
    }
}

/**
 * Matches `CareerFairView.swift`
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CareerFairScreen(onClose: () -> Unit) {
    var searchText by remember { mutableStateOf("") }
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    val companies = remember {
        listOf(
            "Ford Motor Company" to 114,
            "Stryker" to 142,
            "Dow Chemical" to 178,
            "Caterpillar" to 205,
            "General Motors" to 238,
            "Oshkosh Corp" to 264
        )
    }

    val filtered = companies.filter { (name, _) ->
        searchText.isBlank() || name.contains(searchText, ignoreCase = true)
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = { Text("Fall Career Fair", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            OutlinedTextField(
                value = searchText,
                onValueChange = { searchText = it },
                placeholder = { Text("Search attending companies...") },
                leadingIcon = {
                    Icon(Icons.Default.Search, contentDescription = null, tint = lociAccent)
                },
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White,
                    focusedBorderColor = lociAccent,
                    unfocusedBorderColor = Color.Transparent
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
            )

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(filtered, key = { it.first }) { (company, booth) ->
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = Color.White,
                        shadowElevation = 2.dp,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(20.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Text(
                                    text = company,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 17.sp,
                                    color = Color(0xFF1A1A2E)
                                )
                                Text(
                                    text = "Booth: $booth • SDC Multipurpose Room",
                                    fontSize = 13.sp,
                                    color = Color.Gray
                                )
                            }
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                                contentDescription = null,
                                tint = lociAccent.copy(alpha = 0.6f)
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 * Matches `HomeworkPlannerView.swift`, `AddItemView.swift`, and `ToDoList.swift`
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeworkPlannerScreen(onClose: () -> Unit) {
    val context = LocalContext.current
    val repo = remember { ToDoRepository(context) }
    val items = remember { mutableStateListOf<ToDoItem>().apply { addAll(repo.loadItems()) } }

    var isEditing by remember { mutableStateOf(false) }
    var showingAddItemSheet by remember { mutableStateOf(false) }

    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent
    val dateFormat = remember { SimpleDateFormat("MMM d, yyyy", Locale.US) }

    fun persist() {
        repo.saveItems(items.toList())
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = { Text("TaskFlow Planner", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Back", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                actions = {
                    TextButton(onClick = { isEditing = !isEditing }) {
                        Text(
                            text = if (isEditing) "Done" else "Edit",
                            color = lociAccent,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    IconButton(onClick = { showingAddItemSheet = true }) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Add New Task",
                            tint = lociAccent
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        if (items.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "No tasks scheduled yet",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp,
                        color = lociAccent
                    )
                    Text(
                        text = "Tap the + button in the top right to add an Assignment, Exam, Project, or Reading.",
                        fontSize = 14.sp,
                        color = Color.DarkGray
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    ModernButton(
                        text = "Add First Task",
                        onClick = { showingAddItemSheet = true }
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .padding(horizontal = 20.dp, vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                itemsIndexed(items, key = { _, item -> item.id }) { index, item ->
                    Surface(
                        onClick = {
                            if (!isEditing) {
                                items[index] = item.copy(isCompleted = !item.isCompleted)
                                persist()
                            }
                        },
                        shape = RoundedCornerShape(16.dp),
                        color = Color.White,
                        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
                        shadowElevation = 1.dp,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(
                                imageVector = if (item.isCompleted) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
                                contentDescription = "Toggle Done",
                                tint = if (item.isCompleted) lociAccent else LociBrandState.check,
                                modifier = Modifier.size(22.dp)
                            )

                            Column(
                                modifier = Modifier.weight(1f),
                                verticalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(
                                    text = item.priority,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 16.sp,
                                    color = if (item.isCompleted) LociBrandState.sub else LociBrandState.ink
                                )
                                Text(
                                    text = item.classes,
                                    fontWeight = FontWeight.SemiBold,
                                    fontSize = 13.sp,
                                    color = lociAccent
                                )
                                if (item.description.isNotBlank()) {
                                    Text(
                                        text = item.description,
                                        fontSize = 13.sp,
                                        color = LociBrandState.sub
                                    )
                                }
                            }

                            Text(
                                text = dateFormat.format(Date(item.dueDateMillis)),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = LociBrandState.sub
                            )

                            if (isEditing) {
                                Spacer(modifier = Modifier.width(8.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    IconButton(
                                        enabled = index > 0,
                                        onClick = {
                                            if (index > 0) {
                                                val moved = items.removeAt(index)
                                                items.add(index - 1, moved)
                                                persist()
                                            }
                                        }
                                    ) {
                                        Icon(Icons.Default.ArrowUpward, contentDescription = "Move Up", tint = lociAccent)
                                    }
                                    IconButton(
                                        enabled = index < items.lastIndex,
                                        onClick = {
                                            if (index < items.lastIndex) {
                                                val moved = items.removeAt(index)
                                                items.add(index + 1, moved)
                                                persist()
                                            }
                                        }
                                    ) {
                                        Icon(Icons.Default.ArrowDownward, contentDescription = "Move Down", tint = lociAccent)
                                    }
                                    IconButton(
                                        onClick = {
                                            items.removeAt(index)
                                            persist()
                                        }
                                    ) {
                                        Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color(0xFFD32F2F))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (showingAddItemSheet) {
        ModalBottomSheet(
            onDismissRequest = { showingAddItemSheet = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = lociBackground
        ) {
            AddItemSheetContent(
                onCancel = { showingAddItemSheet = false },
                onSave = { newItem ->
                    items.add(newItem)
                    persist()
                    showingAddItemSheet = false
                }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddItemSheetContent(
    onCancel: () -> Unit,
    onSave: (ToDoItem) -> Unit
) {
    val priorities = listOf("Choose One", "Assignment", "Exam", "Project", "Reading", "Other")
    val courses = listOf("Choose One", "MIS3100", "MIS4000", "HU2130", "HU2700", "Other")

    var priority by remember { mutableStateOf("Choose One") }
    var course by remember { mutableStateOf("Choose One") }
    var description by remember { mutableStateOf("") }
    var dueDateMillis by remember { mutableStateOf(System.currentTimeMillis()) }

    var priorityExpanded by remember { mutableStateOf(false) }
    var courseExpanded by remember { mutableStateOf(false) }
    var showDatePicker by remember { mutableStateOf(false) }
    var showingAlert by remember { mutableStateOf(false) }

    val dateFormat = remember { SimpleDateFormat("MMM d, yyyy", Locale.US) }
    val lociAccent = LociBrandState.accent

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp)
            .padding(bottom = 32.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(onClick = onCancel) {
                Text("Cancel", color = lociAccent, fontWeight = FontWeight.Bold)
            }
            Text("Add New Task", fontWeight = FontWeight.Bold, fontSize = 18.sp)
            TextButton(
                onClick = {
                    if (priority != "Choose One" && course != "Choose One" && priority.isNotBlank() && course.isNotBlank()) {
                        onSave(
                            ToDoItem(
                                id = UUID.randomUUID().toString(),
                                priority = priority,
                                classes = course,
                                description = description.trim(),
                                dueDateMillis = dueDateMillis
                            )
                        )
                    } else {
                        showingAlert = true
                    }
                }
            ) {
                Text("Save", color = lociAccent, fontWeight = FontWeight.Bold)
            }
        }

        // Type of Assignment Picker
        ExposedDropdownMenuBox(
            expanded = priorityExpanded,
            onExpandedChange = { priorityExpanded = !priorityExpanded }
        ) {
            OutlinedTextField(
                value = priority,
                onValueChange = {},
                readOnly = true,
                label = { Text("Type of Assignment") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = priorityExpanded) },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                ),
                modifier = Modifier
                    .menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable)
                    .fillMaxWidth()
            )
            ExposedDropdownMenu(
                expanded = priorityExpanded,
                onDismissRequest = { priorityExpanded = false }
            ) {
                priorities.forEach { option ->
                    DropdownMenuItem(
                        text = { Text(option) },
                        onClick = {
                            priority = option
                            priorityExpanded = false
                        }
                    )
                }
            }
        }

        // Course Picker
        ExposedDropdownMenuBox(
            expanded = courseExpanded,
            onExpandedChange = { courseExpanded = !courseExpanded }
        ) {
            OutlinedTextField(
                value = course,
                onValueChange = {},
                readOnly = true,
                label = { Text("Course") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = courseExpanded) },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                ),
                modifier = Modifier
                    .menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable)
                    .fillMaxWidth()
            )
            ExposedDropdownMenu(
                expanded = courseExpanded,
                onDismissRequest = { courseExpanded = false }
            ) {
                courses.forEach { option ->
                    DropdownMenuItem(
                        text = { Text(option) },
                        onClick = {
                            course = option
                            courseExpanded = false
                        }
                    )
                }
            }
        }

        // Description Field
        OutlinedTextField(
            value = description,
            onValueChange = { description = it },
            label = { Text("Description (Optional)") },
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = Color.White,
                unfocusedContainerColor = Color.White
            ),
            modifier = Modifier.fillMaxWidth()
        )

        // Due Date Row
        Surface(
            onClick = { showDatePicker = true },
            shape = RoundedCornerShape(12.dp),
            color = Color.White,
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Due Date", fontWeight = FontWeight.Medium)
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(Icons.Default.CalendarMonth, contentDescription = null, tint = lociAccent)
                    Text(
                        text = dateFormat.format(Date(dueDateMillis)),
                        color = lociAccent,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
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

    if (showingAlert) {
        AlertDialog(
            onDismissRequest = { showingAlert = false },
            title = { Text("Error") },
            text = { Text("You must choose a task type and course before saving") },
            confirmButton = {
                TextButton(onClick = { showingAlert = false }) {
                    Text("OK")
                }
            }
        )
    }
}

/**
 * Matches `DirectoryContactsView.swift`
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DirectoryContactsScreen(
    onClose: () -> Unit,
    onLocateContactOnMap: (Contact) -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    var contacts by remember { mutableStateOf(ContactRepository.fallbackContacts) }
    var isLoading by remember { mutableStateOf(false) }
    var searchText by remember { mutableStateOf("") }

    fun refreshContacts() {
        scope.launch {
            isLoading = true
            ContactRepository.fetchContacts().onSuccess { fetched ->
                contacts = fetched
            }
            isLoading = false
        }
    }

    LaunchedEffect(Unit) {
        refreshContacts()
    }

    val filteredContacts = remember(contacts, searchText) {
        val q = searchText.trim()
        if (q.isEmpty()) {
            contacts
        } else {
            contacts.filter { c ->
                c.name.contains(q, ignoreCase = true) ||
                    c.department.contains(q, ignoreCase = true) ||
                    c.role.contains(q, ignoreCase = true) ||
                    (c.office ?: "").contains(q, ignoreCase = true)
            }
        }
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = { Text("Directory Contacts", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                actions = {
                    IconButton(onClick = { refreshContacts() }) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                color = lociAccent,
                                strokeWidth = 2.dp,
                                modifier = Modifier.size(20.dp)
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Refresh",
                                tint = lociAccent
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedTextField(
                value = searchText,
                onValueChange = { searchText = it },
                placeholder = { Text("Search name, role, building, or department...") },
                leadingIcon = {
                    Icon(Icons.Default.Search, contentDescription = null, tint = lociAccent)
                },
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color.White.copy(alpha = 0.95f),
                    unfocusedContainerColor = Color.White.copy(alpha = 0.95f),
                    focusedBorderColor = lociAccent,
                    unfocusedBorderColor = Color.Transparent
                ),
                modifier = Modifier.fillMaxWidth()
            )

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(filteredContacts, key = { it.id }) { contact ->
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = Color.White,
                        shadowElevation = 2.dp,
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
                                Text(
                                    text = contact.name,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 17.sp,
                                    color = Color(0xFF1A1A2E),
                                    modifier = Modifier.weight(1f)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Surface(
                                    shape = CircleShape,
                                    color = lociAccent.copy(alpha = 0.15f)
                                ) {
                                    Text(
                                        text = contact.role,
                                        color = lociAccent,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold,
                                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                    )
                                }
                            }

                            Text(
                                text = contact.department,
                                fontSize = 14.sp,
                                color = Color.Gray
                            )

                            contact.office?.let { office ->
                                Surface(
                                    onClick = { onLocateContactOnMap(contact) },
                                    shape = RoundedCornerShape(10.dp),
                                    color = lociBackground.copy(alpha = 0.45f),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.LocationOn,
                                            contentDescription = null,
                                            tint = lociAccent,
                                            modifier = Modifier.size(16.dp)
                                        )
                                        Text(
                                            text = office,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = lociAccent
                                        )
                                        Text(
                                            text = "• Locate on Map",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color.Gray
                                        )
                                        Spacer(modifier = Modifier.weight(1f))
                                        Icon(
                                            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                                            contentDescription = null,
                                            tint = lociAccent,
                                            modifier = Modifier.size(16.dp)
                                        )
                                    }
                                }
                            }

                            HorizontalDivider()

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(
                                    modifier = Modifier.clickable {
                                        try {
                                            context.startActivity(
                                                Intent(Intent.ACTION_DIAL, Uri.parse("tel:${contact.phone}"))
                                            )
                                        } catch (_: Exception) {
                                        }
                                    },
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
                                        text = contact.phone,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = lociAccent
                                    )
                                }

                                Row(
                                    modifier = Modifier.clickable {
                                        try {
                                            context.startActivity(
                                                Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:${contact.email}"))
                                            )
                                        } catch (_: Exception) {
                                        }
                                    },
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
                                        text = contact.email,
                                        fontSize = 12.sp,
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
