package com.locistoa.app.data

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import com.locistoa.app.ui.theme.LociBrandState
import com.locistoa.app.ui.theme.LociTheme
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.UUID

enum class GavinTab(val id: String, val label: String) {
    HOME("home", "Home"),
    PEOPLE("people", "People"),
    MAP("map", "Map"),
    PLANNER("planner", "Planner"),
    MORE("more", "More")
}

enum class GavinPeopleSubView(val id: String, val label: String) {
    DIR("dir", "Directory"),
    HELP("help", "Get help"),
    DEPTS("depts", "Departments"),
    ORGS("orgs", "Student orgs")
}

enum class GavinPlanMode(val id: String, val label: String) {
    TASKS("tasks", "Tasks"),
    TIMES("times", "My classes"),
    PERIODS("periods", "Periods")
}

enum class GavinMapViewMode(val id: String, val label: String) {
    INTERACTIVE("interactive", "Live Interactive Map"),
    DIAGRAM("diagram", "Campus Diagram")
}

enum class GavinActiveSheet {
    EMERGENCY,
    CONTACT,
    ADD_TASK,
    ADD_CLASS,
    SEARCH
}

data class GavinPerson(
    val id: Int,
    val name: String,
    val role: String,
    val dept: String,
    val office: String,
    val email: String,
    val phone: String,
    val level: Int,
    val fac: Boolean,
    val initials: String,
    val hay: String
)

data class GavinDepartment(
    val name: String,
    val n: Int,
    val hay: String
) {
    val countText: String get() = "$n ${if (n == 1) "person" else "people"}"
}

@Serializable
data class GavinOffice(
    val id: String = "",
    val name: String = "",
    val category: String = "",
    val goHereFor: String = "",
    val keywords: List<String>? = null,
    val location: String? = null,
    val hours: String? = null,
    val phone: String? = null,
    val email: String? = null,
    val website: String? = null,
    val note: String? = null,
    val departments: List<String>? = null
) {
    val hay: String
        get() = "$name $goHereFor ${(keywords ?: emptyList()).joinToString(" ")} $category".lowercase()
}

data class GavinOrg(
    val i: Int,
    val cat: String,
    val name: String,
    val short: String,
    val desc: String,
    val email: String,
    val site: String,
    val hay: String
)

data class GavinSubject(
    val code: String,
    val name: String
)

@Serializable
data class GavinClassItem(
    val id: Long,
    val subj: String,
    val num: String,
    val days: String,
    val start: String,
    val end: String,
    val loc: String
)

@Serializable
data class GavinTaskItem(
    val id: Long,
    val type: String,
    val course: String,
    val description: String = "",
    val dueDateMillis: Long? = null,
    val due: String,
    val done: Boolean = false,
    val toDoItemId: String = UUID.randomUUID().toString()
)

data class GavinMapBuilding(
    val id: String,
    val short: String,
    val name: String,
    val layer: String,
    val x: Float,
    val y: Float,
    val w: Float,
    val h: Float,
    val inside: String
) {
    val bgColor: Color
        get() = layerColor(layer)

    companion object {
        fun layerColor(layer: String): Color = when (layer) {
            "Academic" -> Color(0xFF1F4E79)
            "Services" -> Color(0xFF9C2F5B)
            "Housing" -> Color(0xFF8A5A00)
            "Athletics" -> Color(0xFF2E6B3F)
            else -> Color(0xFF8C939B)
        }
    }
}

data class GavinEmergencyNumber(
    val id: Int,
    val number: String,
    val chip: String,
    val label: String,
    val primary: Boolean
)

data class GavinLingoItem(
    val term: String,
    val meaning: String,
    val buildingId: String,
    val details: String
)

data class GavinFormattedClass(
    val item: GavinClassItem,
    val code: String,
    val name: String,
    val time: String,
    val whenText: String
)

data class GavinWeekDay(
    val index: Int,
    val top: String,
    val num: Int,
    val dots: String,
    val on: Boolean
)

@Serializable
private data class GavinSavedState(
    val theme: String? = null,
    val widgets: Map<String, Boolean> = emptyMap(),
    val favs: Map<String, Boolean> = emptyMap(),
    val classes: List<GavinClassItem> = emptyList(),
    val tasks: List<GavinTaskItem> = emptyList(),
    val fridaySchedule: Boolean = false
)

class GavinStore(context: Context) {
    private val appContext = context.applicationContext
    private val prefs = appContext.getSharedPreferences("locistoa_gavin_proto_v3", Context.MODE_PRIVATE)
    private val toDoRepo = ToDoRepository(appContext)
    private val json = Json { ignoreUnknownKeys = true }

    val people: List<GavinPerson>
    val depts: List<GavinDepartment>
    val deptMeta: Map<String, List<String>>
    val offices: List<GavinOffice>
    val orgs: List<GavinOrg>
    val orgCatNames: List<String>
    val subjects: List<GavinSubject>

    // Navigation & View State
    var tab by mutableStateOf(GavinTab.HOME)
    var calDay by mutableStateOf<Int?>(null)
    var pv by mutableStateOf(GavinPeopleSubView.DIR)
    var planMode by mutableStateOf(GavinPlanMode.TASKS)
    var mapMode by mutableStateOf(GavinMapViewMode.INTERACTIVE)
    var fridayScheduleEnabled by mutableStateOf(false)

    // People / Directory / Depts / Help / Orgs State
    var dirQuery by mutableStateOf("")
    var filter by mutableStateOf("All")
    var dept by mutableStateOf<String?>(null)
    var deptQuery by mutableStateOf("")
    var office by mutableStateOf<String?>(null)
    var helpQuery by mutableStateOf("")
    var org by mutableStateOf<Int?>(null)
    var orgQuery by mutableStateOf("")
    var orgCat by mutableStateOf("All")

    // Sheets, Modals & Toasts
    var sheet by mutableStateOf<GavinActiveSheet?>(null)
    var contactId by mutableStateOf<Int?>(null)
    var query by mutableStateOf("")
    var toast by mutableStateOf<Pair<String, Long>?>(null)

    // Map Diagram State
    var layer by mutableStateOf("All")
    var building by mutableStateOf<String?>("rekhi")
    var floor by mutableStateOf("1F")

    // Persisted collections
    val widgets = mutableStateMapOf<String, Boolean>()
    val favs = mutableStateMapOf<String, Boolean>()
    val classes = mutableStateListOf<GavinClassItem>()
    val tasks = mutableStateListOf<GavinTaskItem>()

    // Server-synced contacts list
    var serverContacts by mutableStateOf(ContactRepository.fallbackContacts)
    var isSyncingServer by mutableStateOf(false)

    init {
        val phoneByEmail = mutableMapOf<String, String>()
        val officeByEmail = mutableMapOf<String, String>()
        for (c in ContactRepository.fallbackContacts) {
            phoneByEmail[c.email.lowercase()] = c.phone
            if (!c.office.isNullOrBlank()) {
                officeByEmail[c.email.lowercase()] = c.office
            }
        }

        var parsedPeople = emptyList<GavinPerson>()
        var parsedDepts = emptyList<GavinDepartment>()
        var parsedDeptMeta = emptyMap<String, List<String>>()
        var parsedOffices = emptyList<GavinOffice>()
        var parsedOrgs = emptyList<GavinOrg>()
        var parsedOrgCats = emptyList<String>()
        var parsedSubjects = emptyList<GavinSubject>()

        try {
            val rawString = appContext.assets.open("GavinPrototypeData.json").bufferedReader().use { it.readText() }
            val root = json.parseToJsonElement(rawString).jsonObject

            // DM
            val dmObj = root["DM"]?.jsonObject
            if (dmObj != null) {
                parsedDeptMeta = dmObj.mapValues { (_, v) ->
                    v.jsonArray.map { it.jsonPrimitive.content }
                }
            }

            // S
            val sArr = root["S"]?.jsonArray
            if (sArr != null) {
                parsedSubjects = sArr.mapNotNull { item ->
                    val pair = item.jsonArray
                    if (pair.size >= 2) {
                        GavinSubject(pair[0].jsonPrimitive.content, pair[1].jsonPrimitive.content)
                    } else null
                }
            }

            // P
            val pArr = root["P"]?.jsonArray
            if (pArr != null) {
                val pList = ArrayList<GavinPerson>(pArr.size)
                val counts = mutableMapOf<String, Int>()
                pArr.forEachIndexed { idx, elem ->
                    val row = elem.jsonArray
                    if (row.size >= 7) {
                        val name = row[0].jsonPrimitive.content
                        val role = row[1].jsonPrimitive.content
                        val deptName = row[2].jsonPrimitive.content
                        val rawOffice = row[3].jsonPrimitive.content
                        val rawEmail = row[4].jsonPrimitive.content
                        val email = if (rawEmail.contains("@")) rawEmail else "$rawEmail@mtu.edu"
                        val off = if (rawOffice.isBlank()) (officeByEmail[email.lowercase()] ?: "Not listed") else rawOffice
                        val ph = phoneByEmail[email.lowercase()] ?: "906-487-1885"
                        val level = (row[5] as? JsonPrimitive)?.intOrNull ?: row[5].jsonPrimitive.content.toIntOrNull() ?: 10
                        val facInt = (row[6] as? JsonPrimitive)?.intOrNull ?: row[6].jsonPrimitive.content.toIntOrNull() ?: 0
                        val fac = facInt != 0

                        val cleaned = name.replace(Regex("[^A-Za-z .'-]"), "")
                        val parts = cleaned.split(" ").filter { it.isNotBlank() }
                        val firstChar = parts.firstOrNull()?.firstOrNull()?.toString() ?: "?"
                        val lastChar = if (parts.size > 1) (parts.lastOrNull()?.firstOrNull()?.toString() ?: "") else ""
                        val initials = (firstChar + lastChar).uppercase()
                        val hay = "$name $role $deptName $off".lowercase()

                        pList.add(
                            GavinPerson(
                                id = idx,
                                name = name,
                                role = role,
                                dept = deptName,
                                office = off,
                                email = email,
                                phone = ph,
                                level = level,
                                fac = fac,
                                initials = initials,
                                hay = hay
                            )
                        )
                        counts[deptName] = (counts[deptName] ?: 0) + 1
                    }
                }
                parsedPeople = pList
                parsedDepts = counts.keys.sorted().map { dName ->
                    GavinDepartment(name = dName, n = counts[dName] ?: 0, hay = dName.lowercase())
                }
            }

            // F
            val fElem = root["F"]
            if (fElem != null) {
                parsedOffices = json.decodeFromJsonElement(
                    kotlinx.serialization.builtins.ListSerializer(GavinOffice.serializer()),
                    fElem
                )
            }

            // O
            val oArr = root["O"]?.jsonArray
            if (oArr != null) {
                val oList = ArrayList<GavinOrg>(oArr.size)
                val cats = sortedSetOf<String>()
                oArr.forEachIndexed { idx, elem ->
                    val row = elem.jsonArray
                    if (row.size >= 6) {
                        val cat = row[0].jsonPrimitive.content
                        val name = row[1].jsonPrimitive.content
                        val shortName = row[2].jsonPrimitive.content
                        val rawDesc = row[3].jsonPrimitive.content
                        val desc = if (rawDesc.isBlank()) "No description listed." else rawDesc
                        val email = row[4].jsonPrimitive.content
                        val site = row[5].jsonPrimitive.content
                        cats.add(cat)
                        oList.add(
                            GavinOrg(
                                i = idx,
                                cat = cat,
                                name = name,
                                short = shortName,
                                desc = desc,
                                email = email,
                                site = site,
                                hay = "$name $shortName $cat".lowercase()
                            )
                        )
                    }
                }
                parsedOrgs = oList
                parsedOrgCats = cats.toList()
            }
        } catch (_: Exception) {
        }

        people = parsedPeople
        depts = parsedDepts
        deptMeta = parsedDeptMeta
        offices = parsedOffices
        orgs = parsedOrgs
        orgCatNames = parsedOrgCats
        subjects = parsedSubjects

        loadPersistedState()
        syncFromToDoRepo()
    }

    private fun loadPersistedState() {
        val raw = prefs.getString("state", null)
        if (raw != null) {
            try {
                val saved = json.decodeFromString<GavinSavedState>(raw)
                saved.theme?.let { LociBrandState.theme = LociTheme.fromId(it) }
                widgets.clear()
                widgets.putAll(saved.widgets)
                favs.clear()
                favs.putAll(saved.favs)
                classes.clear()
                classes.addAll(saved.classes)
                tasks.clear()
                tasks.addAll(saved.tasks)
                fridayScheduleEnabled = saved.fridaySchedule
            } catch (_: Exception) {
            }
        }
        if (classes.isEmpty()) {
            // Helpful default MTU classes if none exist yet
            classes.addAll(
                listOf(
                    GavinClassItem(1L, "CS", "1121", "MWF", "10:00", "10:50", "Rekhi 214"),
                    GavinClassItem(2L, "MIS", "3100", "TR", "11:00", "12:15", "AOB 101"),
                    GavinClassItem(3L, "HU", "2130", "MWF", "13:00", "13:50", "Walker 134")
                )
            )
        }
    }

    fun persistState() {
        try {
            val saved = GavinSavedState(
                theme = LociBrandState.theme.id,
                widgets = widgets.toMap(),
                favs = favs.toMap(),
                classes = classes.toList(),
                tasks = tasks.toList(),
                fridaySchedule = fridayScheduleEnabled
            )
            prefs.edit().putString("state", json.encodeToString(saved)).apply()
        } catch (_: Exception) {
        }
    }

    fun syncFromToDoRepo() {
        val repoItems = toDoRepo.loadItems()
        if (repoItems.isNotEmpty()) {
            tasks.clear()
            repoItems.forEachIndexed { idx, item ->
                tasks.add(
                    GavinTaskItem(
                        id = (item.id.hashCode().toLong() and 0x7FFFFFFFL) + idx,
                        type = item.priority.ifBlank { "Assignment" },
                        course = item.classes.ifBlank { "Other" },
                        description = item.description,
                        dueDateMillis = item.dueDateMillis,
                        due = formatDueDate(item.dueDateMillis),
                        done = item.isCompleted,
                        toDoItemId = item.id
                    )
                )
            }
            persistState()
        } else if (tasks.isNotEmpty()) {
            syncToDoRepoFromTasks()
        } else {
            // Seed initial sample tasks so Due soon & TaskFlow Planner are immediately rich
            val now = System.currentTimeMillis()
            val dayMs = 86_400_000L
            tasks.addAll(
                listOf(
                    GavinTaskItem(
                        id = 101L,
                        type = "Assignment",
                        course = "CS 1121",
                        description = "Lab 4: Rekhi Hall Indoor Graph Routing",
                        dueDateMillis = now + dayMs,
                        due = formatDueDate(now + dayMs),
                        done = false
                    ),
                    GavinTaskItem(
                        id = 102L,
                        type = "Project",
                        course = "MIS 3100",
                        description = "Systems Analysis Deliverable & ER Diagram",
                        dueDateMillis = now + 3 * dayMs,
                        due = formatDueDate(now + 3 * dayMs),
                        done = false
                    )
                )
            )
            syncToDoRepoFromTasks()
            persistState()
        }
    }

    fun syncToDoRepoFromTasks() {
        val mapped = tasks.map { t ->
            ToDoItem(
                id = t.toDoItemId,
                priority = t.type,
                classes = t.course,
                description = t.description,
                dueDateMillis = t.dueDateMillis ?: System.currentTimeMillis(),
                isCompleted = t.done
            )
        }
        toDoRepo.saveItems(mapped)
        persistState()
    }

    fun go(
        targetTab: GavinTab,
        subView: GavinPeopleSubView? = null,
        targetPlanMode: GavinPlanMode? = null,
        resetPeopleSelection: Boolean = false,
        targetDept: String? = null,
        targetOffice: String? = null,
        targetOrg: Int? = null,
        targetBuilding: String? = null,
        targetFloor: String? = null,
        targetLayer: String? = null
    ) {
        tab = targetTab
        sheet = null
        if (resetPeopleSelection) {
            dept = null
            office = null
            org = null
        }
        if (subView != null) pv = subView
        if (targetPlanMode != null) planMode = targetPlanMode
        if (targetDept != null) dept = targetDept
        if (targetOffice != null) office = targetOffice
        if (targetOrg != null) org = targetOrg
        if (targetBuilding != null) building = targetBuilding
        if (targetFloor != null) floor = targetFloor
        if (targetLayer != null) layer = targetLayer
    }

    fun isWidgetEnabled(key: String): Boolean {
        return widgets[key] ?: widgetDefinitions.firstOrNull { it.first == key }?.fourth ?: false
    }

    fun toggleWidget(key: String) {
        widgets[key] = !isWidgetEnabled(key)
        persistState()
    }

    fun toggleTask(id: Long) {
        val idx = tasks.indexOfFirst { it.id == id }
        if (idx >= 0) {
            val current = tasks[idx]
            val nowDone = !current.done
            tasks[idx] = current.copy(done = nowDone)
            toast = if (nowDone) ("Marked done" to id) else null
            syncToDoRepoFromTasks()
        }
    }

    fun deleteTask(id: Long) {
        tasks.removeAll { it.id == id }
        syncToDoRepoFromTasks()
    }

    fun addTask(type: String, course: String, description: String, dueDateMillis: Long?) {
        val dueText = if (dueDateMillis != null) formatDueDate(dueDateMillis) else "No date"
        val newTask = GavinTaskItem(
            id = System.currentTimeMillis(),
            type = type,
            course = course,
            description = description.trim(),
            dueDateMillis = dueDateMillis,
            due = dueText,
            done = false,
            toDoItemId = UUID.randomUUID().toString()
        )
        tasks.add(newTask)
        syncToDoRepoFromTasks()
        sheet = null
    }

    fun addClass(subj: String, num: String, days: String, start: String, end: String, loc: String) {
        classes.add(
            GavinClassItem(
                id = System.currentTimeMillis(),
                subj = subj,
                num = num,
                days = days,
                start = start,
                end = end,
                loc = loc.trim()
            )
        )
        persistState()
        sheet = null
    }

    fun removeClass(id: Long) {
        classes.removeAll { it.id == id }
        persistState()
    }

    fun toggleFav(email: String) {
        val cur = favs[email] == true
        favs[email] = !cur
        persistState()
    }

    fun contactForPerson(person: GavinPerson): Contact {
        val match = serverContacts.firstOrNull {
            it.email.equals(person.email, ignoreCase = true) ||
                it.name.equals(person.name, ignoreCase = true)
        }
        if (match != null) return match
        return Contact(
            id = "gavin-${person.id}",
            name = person.name,
            role = person.role,
            department = person.dept,
            email = person.email,
            phone = person.phone,
            office = if (person.office == "Not listed") null else person.office
        )
    }

    val currentContact: GavinPerson?
        get() {
            val id = contactId ?: return null
            return people.getOrNull(id)
        }

    val savedContacts: List<GavinPerson>
        get() = people.filter { favs[it.email] == true }

    fun subjName(code: String): String {
        return subjects.firstOrNull { it.code.equals(code, ignoreCase = true) }?.name ?: "Michigan Tech Course"
    }

    val sortedClasses: List<GavinFormattedClass>
        get() = classes.sortedBy { mins(it.start) }.map { k ->
            val code = "${k.subj} ${k.num}"
            val dayText = daysInfo.filter { k.days.contains(it.first) }.joinToString(", ") { it.second }
            val time = "${fmt(k.start)} – ${fmt(k.end)}"
            val locSuffix = if (k.loc.isBlank()) "" else " · ${k.loc}"
            GavinFormattedClass(
                item = k,
                code = code,
                name = subjName(k.subj),
                time = time,
                whenText = "$dayText · $time$locSuffix"
            )
        }

    val nextClassInfo: Triple<String, String, String>?
        get() {
            val cal = Calendar.getInstance()
            val nowMin = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
            val jsDay = cal.get(Calendar.DAY_OF_WEEK) - 1 // 0=Sun..6=Sat
            val letters = listOf("", "M", "T", "W", "R", "F", "")
            val dayNames = listOf("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
            val allSorted = sortedClasses
            for (d in 0 until 7) {
                val wd = (jsDay + d) % 7
                val letter = letters[wd]
                if (letter.isEmpty()) continue
                val todays = allSorted.filter { entry ->
                    entry.item.days.contains(letter) && (d > 0 || mins(entry.item.end) > nowMin)
                }
                val first = todays.firstOrNull()
                if (first != null) {
                    val live = (d == 0 && mins(first.item.start) <= nowMin)
                    val locSuffix = if (first.item.loc.isBlank()) "" else " · ${first.item.loc}"
                    val line = "${first.time}$locSuffix"
                    val dayLabel = when (d) {
                        0 -> "Today"
                        1 -> "Tomorrow"
                        else -> dayNames[wd]
                    }
                    val label = if (live) "Happening now" else "Up next · $dayLabel"
                    return Triple(first.code, line, label)
                }
            }
            return null
        }

    val selectedCalDayIndex: Int
        get() {
            calDay?.let { return it }
            val jsDay = Calendar.getInstance().get(Calendar.DAY_OF_WEEK) - 1
            return if (jsDay in 1..5) jsDay - 1 else 0
        }

    val weekCalendarDays: List<GavinWeekDay>
        get() {
            val now = Calendar.getInstance()
            val dow = now.get(Calendar.DAY_OF_WEEK) - 1
            val offsetToMonday = when (dow) {
                0 -> 1
                6 -> 2
                else -> 1 - dow
            }
            val monday = (now.clone() as Calendar).apply {
                add(Calendar.DAY_OF_MONTH, offsetToMonday)
            }
            val sel = selectedCalDayIndex
            return daysInfo.mapIndexed { i, d ->
                val dayCal = (monday.clone() as Calendar).apply {
                    add(Calendar.DAY_OF_MONTH, i)
                }
                val isToday = dayCal.get(Calendar.YEAR) == now.get(Calendar.YEAR) &&
                    dayCal.get(Calendar.DAY_OF_YEAR) == now.get(Calendar.DAY_OF_YEAR)
                val dayNum = dayCal.get(Calendar.DAY_OF_MONTH)
                val count = classes.count { it.days.contains(d.first) }
                val dots = "•".repeat(minOf(count, 4))
                GavinWeekDay(
                    index = i,
                    top = if (isToday) "Today" else d.second,
                    num = dayNum,
                    dots = dots,
                    on = sel == i
                )
            }
        }

    val selectedCalDayClasses: List<GavinFormattedClass>
        get() {
            val code = daysInfo[selectedCalDayIndex].first
            return sortedClasses.filter { it.item.days.contains(code) }
        }

    val dueSoonTasks: List<GavinTaskItem>
        get() = tasks.filter { !it.done }.take(3)

    val courseOptionsForTask: List<String>
        get() {
            val opts = mutableListOf<String>()
            sortedClasses.forEach { if (!opts.contains(it.code)) opts.add(it.code) }
            listOf("MIS3100", "MIS4000", "HU2130", "HU2700", "Other").forEach {
                if (!opts.contains(it)) opts.add(it)
            }
            return opts
        }

    val filteredDirectoryPeople: List<GavinPerson>
        get() {
            val dq = dirQuery.trim().lowercase()
            return people.filter { c ->
                val matchesRole = (filter == "All") || ((filter == "Faculty") == c.fac)
                val matchesQuery = dq.isEmpty() || c.hay.contains(dq)
                matchesRole && matchesQuery
            }
        }

    val filteredDepartments: List<GavinDepartment>
        get() {
            val dpq = deptQuery.trim().lowercase()
            return depts.filter { dpq.isEmpty() || it.hay.contains(dpq) }
        }

    val currentDeptPeopleGrouped: List<Triple<String, List<GavinPerson>, Boolean>>
        get() {
            val targetDept = dept ?: return emptyList()
            val members = people.filter { it.dept == targetDept }.sortedWith(
                compareBy<GavinPerson> { it.level }.thenBy { it.name }
            )
            val leadership = members.filter { it.level <= 8 }
            val faculty = members.filter { it.level > 8 && it.fac }
            val staff = members.filter { it.level > 8 && !it.fac }
            val groups = mutableListOf<Triple<String, List<GavinPerson>, Boolean>>()
            if (leadership.isNotEmpty()) groups.add(Triple("Leadership", leadership, true))
            if (faculty.isNotEmpty()) groups.add(Triple("Faculty", faculty, true))
            if (staff.isNotEmpty()) groups.add(Triple("Staff", staff, true))
            return groups
        }

    val filteredHelpOffices: List<Pair<GavinOffice, Boolean>>
        get() {
            val hq = helpQuery.trim().lowercase()
            val matches = offices.filter { hq.isEmpty() || it.hay.contains(hq) }
            return matches.mapIndexed { idx, off ->
                val showHead = (idx == 0) || (matches[idx - 1].category != off.category)
                off to showHead
            }
        }

    val currentOffice: GavinOffice?
        get() = office?.let { id -> offices.firstOrNull { it.id == id } }

    val filteredOrgs: List<GavinOrg>
        get() {
            val oq = orgQuery.trim().lowercase()
            return orgs.filter { o ->
                val matchesCat = (orgCat == "All") || (o.cat == orgCat)
                val matchesQuery = oq.isEmpty() || o.hay.contains(oq)
                matchesCat && matchesQuery
            }
        }

    val currentOrg: GavinOrg?
        get() = org?.let { orgs.getOrNull(it) }

    val orgOfTheDay: GavinOrg?
        get() {
            if (orgs.isEmpty()) return null
            val dayIndex = ((System.currentTimeMillis() / 86_400_000L) % orgs.size).toInt()
            return orgs[dayIndex]
        }

    val selectedMapBuilding: GavinMapBuilding?
        get() = building?.let { id -> mapBuildings.firstOrNull { it.id == id } }

    companion object {
        val daysInfo = listOf(
            "M" to "Mon",
            "T" to "Tue",
            "W" to "Wed",
            "R" to "Thu",
            "F" to "Fri"
        )

        val regularPeriodTimes = listOf(
            "08:30 - 09:18",
            "09:22 - 10:08",
            "10:13 - 11:07",
            "11:12 - 11:58",
            "12:03 - 12:49",
            "12:54 - 01:40",
            "01:45 - 02:31",
            "02:36 - 03:22"
        )

        val fridayPeriodTimes = listOf(
            "08:30 - 09:17",
            "09:22 - 10:08",
            "10:13 - 11:07",
            "11:12 - 11:58",
            "12:03 - 12:49",
            "12:54 - 01:40",
            "01:45 - 02:31",
            "02:36 - 03:22"
        )

        val widgetDefinitions = listOf(
            Quadruple("next", "Next class", "Your upcoming class", true),
            Quadruple("cal", "This week", "A calendar of your classes", true),
            Quadruple("due", "Due soon", "Tasks from your planner", true),
            Quadruple("tools", "Campus tools", "Live map, schedule, directory, career fair, chatbot & nomenclature", true),
            Quadruple("links", "Quick links", "Canvas, Banweb, and more", true),
            Quadruple("help", "Get help shortcuts", "Common needs, one tap away", true),
            Quadruple("saved", "Saved people", "Contacts you starred", true),
            Quadruple("org", "Student org of the day", "Discover a new organization", false)
        )

        val emergencyNumbers = listOf(
            GavinEmergencyNumber(0, "911", "911", "Police, fire, medical", true),
            GavinEmergencyNumber(1, "906-487-2216", "Public Safety", "Public Safety, answered 24/7", false),
            GavinEmergencyNumber(2, "988", "988 Crisis Line", "Suicide & Crisis Lifeline", false),
            GavinEmergencyNumber(3, "906-487-2538", "Counseling", "Student mental health and counseling", false),
            GavinEmergencyNumber(4, "906-487-3889", "Hall duty phone", "Residence hall duty phone", false),
            GavinEmergencyNumber(5, "906-487-2216", "Tip line", "Anonymous campus safety line", false)
        )

        val mapBuildings = listOf(
            GavinMapBuilding("admin", "Admin", "Administration Building", "Services", 205f, 270f, 64f, 44f, "Registrar, Financial Aid, Dean of Students, Career Services, and more"),
            GavinMapBuilding("aob", "Academic Office", "Academic Office Building", "Academic", 272f, 205f, 70f, 44f, "College of Business, Social Sciences"),
            GavinMapBuilding("rotc", "ROTC", "ROTC Building", "Academic", 338f, 195f, 52f, 40f, "Air Force and Army ROTC"),
            GavinMapBuilding("meem", "MEEM", "R. L. Smith Building (MEEM)", "Academic", 383f, 255f, 60f, 46f, "Mechanical & Aerospace Engineering"),
            GavinMapBuilding("chem", "Chem Sci", "Chemical Sciences & Engineering Building", "Academic", 452f, 250f, 60f, 46f, "Chemical Engineering, Chemistry"),
            GavinMapBuilding("hstem", "H-STEM", "H-STEM Engineering & Health Technologies Complex", "Academic", 478f, 301f, 52f, 38f, "Health, Human & Biological Systems; Biomedical Engineering; Kinesiology"),
            GavinMapBuilding("glrc", "GLRC", "Great Lakes Research Center", "Academic", 560f, 150f, 60f, 38f, "Research center on the waterfront"),
            GavinMapBuilding("dow", "Dow", "Dow Environmental Sciences & Engineering Building", "Academic", 602f, 228f, 64f, 44f, "Biological Sciences; Civil, Environmental & Geospatial Engineering; Geological & Mining Engineering"),
            GavinMapBuilding("eerc", "EERC", "Electrical Energy Resources Center", "Academic", 538f, 289f, 56f, 42f, "Electrical & Computer Engineering; Manufacturing & Mechanical Engineering Technology"),
            GavinMapBuilding("dillman", "Dillman", "Grover C. Dillman Hall", "Academic", 625f, 306f, 60f, 40f, "Engineering Fundamentals"),
            GavinMapBuilding("mm", "M&M", "Minerals & Materials Engineering Building", "Academic", 716f, 328f, 60f, 44f, "Materials Science & Engineering; Psychology & Human Factors"),
            GavinMapBuilding("mub", "MUB", "Memorial Union Building", "Services", 382f, 331f, 70f, 44f, "Welcome Center, Campus Store, dining"),
            GavinMapBuilding("lib", "Library", "Van Pelt and Opie Library", "Services", 473f, 362f, 64f, 44f, "Study space, archives, Center for Teaching & Learning"),
            GavinMapBuilding("rekhi", "Rekhi", "Kanwal & Ann Rekhi Hall", "Academic", 545f, 392f, 60f, 42f, "College of Computing, Applied Computing, Computer Science"),
            GavinMapBuilding("fisher", "Fisher", "Fisher Hall", "Academic", 615f, 432f, 60f, 42f, "Physics, Mathematical Sciences"),
            GavinMapBuilding("dhh", "DHH", "Douglass Houghton Hall", "Housing", 792f, 375f, 70f, 42f, "Residence hall"),
            GavinMapBuilding("walker", "Walker", "Walker Arts & Humanities Center", "Academic", 868f, 462f, 60f, 40f, "College of Sciences & Arts, Humanities, Visual & Performing Arts"),
            GavinMapBuilding("rozsa", "Rozsa", "Rozsa Center for the Performing Arts", "Academic", 938f, 420f, 62f, 40f, "Concerts, theatre, and events"),
            GavinMapBuilding("east", "East Hall", "East Hall", "Housing", 955f, 512f, 70f, 34f, "Residence hall"),
            GavinMapBuilding("wads", "Wadsworth", "Wadsworth Hall", "Housing", 770f, 577f, 150f, 40f, "Residence hall and dining"),
            GavinMapBuilding("mcnair", "McNair", "West and East McNair Halls", "Housing", 935f, 618f, 84f, 40f, "Residence halls and dining"),
            GavinMapBuilding("noblet", "Noblet", "U. J. Noblet Forestry Building", "Academic", 515f, 632f, 70f, 42f, "College of Forest Resources & Environmental Science"),
            GavinMapBuilding("sdc", "SDC", "Student Development Complex", "Athletics", 690f, 668f, 90f, 44f, "Recreation, fitness, athletics, and the student health clinic")
        )

        val campusLingo = listOf(
            GavinLingoItem("MUB", "Memorial Union Building", "mub", "Student union with the Campus Store, MUB Commons dining, Ballroom, and Student Leadership & Involvement."),
            GavinLingoItem("Wads", "Wadsworth Hall", "wads", "Largest residence hall on US-41, home to the Dining Hall, Campus Cafe, and Residence Education & Housing Services."),
            GavinLingoItem("MEEM", "Mechanical Engineering-Engineering Mechanics Building", "meem", "Officially the R. L. Smith Building; campus tallest academic tower connected to the heated skywalk network."),
            GavinLingoItem("SDC", "Student Development Complex", "sdc", "Athletics, MacInnes Student Ice Arena, multipurpose gym, pool, fitness center, and health clinic."),
            GavinLingoItem("Rekhi", "Kanwal & Ann Rekhi Hall", "rekhi", "Home of the College of Computing, Computer Science, Applied Computing, and 24/7 student computing labs."),
            GavinLingoItem("EERC", "Electrical Energy Resources Center", "eerc", "Home to Electrical & Computer Engineering, Alley Makerspace, and robotics/automation labs."),
            GavinLingoItem("AOB", "Academic Office Building", "aob", "Home to the College of Business, Economics, Accounting, MIS, and Social Sciences."),
            GavinLingoItem("DHH", "Douglass Houghton Hall", "dhh", "Historic castle-style residence hall near Fisher Hall and the Library."),
            GavinLingoItem("GLRC", "Great Lakes Research Center", "glrc", "Waterfront research facility on the Portage Waterway."),
            GavinLingoItem("M&M", "Minerals & Materials Engineering Building", "mm", "Materials Science & Engineering, Psychology & Human Factors, and U05 Foundry Corridor.")
        )

        fun formatDueDate(millis: Long): String {
            val df = SimpleDateFormat("MMM d, yyyy", Locale.US)
            return df.format(Date(millis))
        }

        fun fmt(timeStr: String): String {
            val parts = timeStr.split(":")
            val h = parts.getOrNull(0)?.toIntOrNull() ?: 0
            val m = parts.getOrNull(1)?.toIntOrNull() ?: 0
            val h12 = if (h % 12 == 0) 12 else (h % 12)
            val mPad = if (m < 10) "0$m" else "$m"
            val ampm = if (h >= 12) "PM" else "AM"
            return "$h12:$mPad $ampm"
        }

        fun mins(timeStr: String): Int {
            val parts = timeStr.split(":")
            val h = parts.getOrNull(0)?.toIntOrNull() ?: 0
            val m = parts.getOrNull(1)?.toIntOrNull() ?: 0
            return h * 60 + m
        }
    }
}

data class Quadruple<A, B, C, D>(val first: A, val second: B, val third: C, val fourth: D)
