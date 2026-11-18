package com.locistoa.app.data

import com.locistoa.app.ui.theme.LociBrandState
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.net.HttpURLConnection
import java.net.URL

@Serializable
data class Contact(
    val id: String,
    val name: String,
    val role: String,
    val department: String,
    val email: String,
    val phone: String,
    val office: String? = null
)

object ContactRepository {
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun fetchContacts(): Result<List<Contact>> = withContext(Dispatchers.IO) {
        val urlsToTry = listOf(
            "http://${LociBrandState.serverIp}:8080/api/contacts",
            "http://10.0.2.2:8080/api/contacts",
            "http://127.0.0.1:8080/api/contacts"
        )

        for (urlString in urlsToTry) {
            try {
                val url = URL(urlString)
                val conn = (url.openConnection() as HttpURLConnection).apply {
                    requestMethod = "GET"
                    connectTimeout = 2200
                    readTimeout = 2500
                }
                val code = conn.responseCode
                if (code in 200..299) {
                    val body = conn.inputStream.bufferedReader().use { it.readText() }
                    val parsed = json.decodeFromString<List<Contact>>(body)
                    if (parsed.isNotEmpty()) {
                        return@withContext Result.success(parsed)
                    }
                }
            } catch (_: Exception) {
                // Continue to next endpoint or fallback
            }
        }

        // Complete verified 76-contact MTU directory fallback so offline navigation works seamlessly
        Result.success(fallbackContacts)
    }

    val fallbackContacts: List<Contact> = listOf(
        Contact(id = "mtu-svc-001", name = "Registrar's Office", role = "Campus Office", department = "Student Affairs & Enrollment", email = "registrar@mtu.edu", phone = "906-487-2319", office = "Administration Building 130"),
        Contact(id = "mtu-svc-002", name = "Dean of Students Office", role = "Student Support", department = "Student Affairs", email = "deanofstudents@mtu.edu", phone = "906-487-2212", office = "Administration Building 130"),
        Contact(id = "mtu-svc-003", name = "Waino Wahtera Center for Student Success", role = "Academic Support", department = "Student Success", email = "success@mtu.edu", phone = "906-487-3558", office = "Administration Building 130"),
        Contact(id = "mtu-svc-004", name = "Student Financial Services & Financial Aid", role = "Financial Support", department = "Administration", email = "finaid@mtu.edu", phone = "906-487-2622", office = "Administration Building 103"),
        Contact(id = "mtu-svc-005", name = "Career Services", role = "Career Advising & Co-ops", department = "Student Affairs", email = "career@mtu.edu", phone = "906-487-2313", office = "Administration Building 220"),
        Contact(id = "mtu-svc-006", name = "Center for Student Mental Health and Well-being", role = "Counseling Services", department = "Health & Wellness", email = "counseling@mtu.edu", phone = "906-487-2538", office = "Administration Building 301"),
        Contact(id = "mtu-svc-007", name = "Public Safety and Police Services", role = "Campus Safety", department = "Public Safety", email = "psps@mtu.edu", phone = "906-487-2216", office = "Widmaier House, 206 MacInnes Dr."),
        Contact(id = "mtu-svc-008", name = "Information Technology (IT) Service Center", role = "Technical Support & HuskyCard", department = "Information Technology", email = "it-help@mtu.edu", phone = "906-487-1111", office = "Van Pelt and Opie Library 101"),
        Contact(id = "mtu-svc-009", name = "Van Pelt and Opie Library", role = "Library Services", department = "Academic Resources", email = "library@mtu.edu", phone = "906-487-2508", office = "Library Service Center, 1st Floor"),
        Contact(id = "mtu-svc-010", name = "Residence Education and Housing Services", role = "Campus Housing", department = "Student Affairs", email = "housing@mtu.edu", phone = "906-487-2682", office = "Wadsworth Hall 153"),
        Contact(id = "mtu-svc-011", name = "Student Leadership and Involvement", role = "Student Orgs & Greek Life", department = "Student Affairs", email = "activities@mtu.edu", phone = "906-487-1963", office = "Memorial Union Building 112"),
        Contact(id = "mtu-svc-012", name = "Student Disability Services", role = "Accessibility Support", department = "Dean of Students", email = "sds@mtu.edu", phone = "906-487-2345", office = "Administration Building 130"),
        Contact(id = "mtu-svc-013", name = "International Programs and Services", role = "International Support", department = "Global Campus & Study Abroad", email = "ips@mtu.edu", phone = "906-487-2160", office = "Administration Building 200"),
        Contact(id = "mtu-svc-014", name = "Graduate School Office", role = "Graduate Programs", department = "Graduate School", email = "gradschool@mtu.edu", phone = "906-487-2327", office = "Administration Building 414"),
        Contact(id = "mtu-svc-015", name = "Undergraduate Admissions", role = "Admissions Office", department = "Enrollment", email = "admissions@mtu.edu", phone = "906-487-2335", office = "McAllister Welcome Center"),
        Contact(id = "mtu-svc-016", name = "Transportation & Parking Services", role = "Parking Permits & Transit", department = "Auxiliary Services", email = "parking@mtu.edu", phone = "906-487-1441", office = "Administration Building 100"),
        Contact(id = "mtu-svc-017", name = "Student Development Complex (SDC)", role = "Athletics & Recreation", department = "Athletics", email = "sdc@mtu.edu", phone = "906-487-2578", office = "Student Development Complex"),
        Contact(id = "mtu-svc-018", name = "Human Resources Office", role = "Campus Employment & HR", department = "Human Resources", email = "hr-help@mtu.edu", phone = "906-487-2280", office = "Lakeshore Center, 2nd Floor"),
        Contact(id = "mtu-cs-001", name = "Zhenlin Wang", role = "Professor and Department Chair", department = "Computer Science", email = "zlwang@mtu.edu", phone = "906-487-2187", office = "Rekhi Hall 322"),
        Contact(id = "mtu-cs-002", name = "Denise Landsberg", role = "Academic Advisor", department = "Computer Science", email = "dllandsb@mtu.edu", phone = "906-487-3643", office = "Rekhi Hall 322"),
        Contact(id = "mtu-cs-003", name = "Janna Chittick", role = "Department Coordinator", department = "Computer Science", email = "zyesmukh@mtu.edu", phone = "906-487-1833", office = "Rekhi Hall 322"),
        Contact(id = "mtu-cs-004", name = "Koloud Al Khamaiseh", role = "Assistant Teaching Professor", department = "Computer Science", email = "kalkhama@mtu.edu", phone = "906-487-3619", office = "Rekhi Hall 310"),
        Contact(id = "mtu-cs-005", name = "Serein Al-Ratrout", role = "Associate Teaching Professor", department = "Computer Science", email = "salratro@mtu.edu", phone = "906-487-2518", office = "Rekhi Hall 104"),
        Contact(id = "mtu-cs-006", name = "Gorkem Asilioglu", role = "Associate Teaching Professor", department = "Computer Science", email = "galolu@mtu.edu", phone = "906-487-1643", office = "Rekhi Hall 308"),
        Contact(id = "mtu-cs-007", name = "Briana Bettin", role = "Associate Professor", department = "Computer Science", email = "bcbettin@mtu.edu", phone = "906-487-1833", office = "Rekhi Hall 211"),
        Contact(id = "mtu-cs-008", name = "Bo Chen", role = "Associate Professor & Director of Cybersecurity", department = "Computer Science", email = "bchen@mtu.edu", phone = "906-487-3149", office = "Rekhi Hall 301"),
        Contact(id = "mtu-cs-009", name = "Ali Ebnenasir", role = "Associate Professor", department = "Computer Science", email = "aebnenas@mtu.edu", phone = "906-487-4372", office = "Rekhi Hall 206"),
        Contact(id = "mtu-cs-010", name = "Timothy C. Havens", role = "Professor & GLRC Executive Director", department = "Computer Science & Data Science", email = "thavens@mtu.edu", phone = "906-487-3115", office = "GLRC 307"),
        Contact(id = "mtu-cs-011", name = "Scott A. Kuhl", role = "Associate Professor", department = "Computer Science", email = "kuhl@mtu.edu", phone = "906-487-2798", office = "Rekhi Hall 210"),
        Contact(id = "mtu-cs-012", name = "Evan Lucas", role = "Assistant Professor", department = "Data Science & Computer Science", email = "eglucas@mtu.edu", phone = "906-487-2094", office = "GLRC 211"),
        Contact(id = "mtu-cs-013", name = "Jean Mayo", role = "Professor & Graduate Program Director", department = "Computer Science", email = "jmayo@mtu.edu", phone = "906-487-3157", office = "Rekhi Hall 304"),
        Contact(id = "mtu-cs-014", name = "Yakov Nekrich", role = "Associate Professor", department = "Computer Science", email = "yakov@mtu.edu", phone = "906-487-2271", office = "Rekhi Hall 311"),
        Contact(id = "mtu-cs-015", name = "Nilufer Onder", role = "Associate Professor & Undergrad Program Director", department = "Computer Science", email = "nilufer@mtu.edu", phone = "906-487-1641", office = "Rekhi Hall 309"),
        Contact(id = "mtu-cs-016", name = "Soner Onder", role = "Professor", department = "Computer Science", email = "soner@mtu.edu", phone = "906-487-2123", office = "Rekhi Hall 303"),
        Contact(id = "mtu-cs-017", name = "Stella Otoo", role = "Assistant Teaching Professor", department = "Computer Science", email = "sotoo@mtu.edu", phone = "906-487-3602", office = "Rekhi Hall 102"),
        Contact(id = "mtu-cs-018", name = "Robert Pastel", role = "Associate Professor", department = "Computer Science", email = "pastel@mtu.edu", phone = "906-487-1639", office = "Rekhi Hall 204"),
        Contact(id = "mtu-cs-019", name = "Leo C. Ureel II", role = "Associate Professor & CCLC Coordinator", department = "Computer Science", email = "ureel@mtu.edu", phone = "906-487-1816", office = "Rekhi Hall 209"),
        Contact(id = "mtu-cs-020", name = "Keith Vertanen", role = "Dave House Professor", department = "Computer Science", email = "vertanen@mtu.edu", phone = "906-487-2331", office = "Rekhi Hall 208"),
        Contact(id = "mtu-cs-021", name = "Anwar Walid", role = "ICC Executive Director & Professor of Practice", department = "Computer Science & Data Science", email = "aiwalid@mtu.edu", phone = "906-487-2514", office = "Rekhi Hall 202"),
        Contact(id = "mtu-cs-022", name = "Michael Walker", role = "Assistant Professor", department = "Computer Science", email = "miwalker@mtu.edu", phone = "906-487-3392", office = "Rekhi Hall 212"),
        Contact(id = "mtu-cs-023", name = "Charles Wallace", role = "Professor", department = "Computer Science", email = "wallace@mtu.edu", phone = "906-487-3431", office = "Rekhi Hall 205"),
        Contact(id = "mtu-cs-024", name = "Jie Wu", role = "Assistant Professor", department = "Computer Science", email = "jie.jw.wu@mtu.edu", phone = "906-487-2320", office = "Rekhi Hall 207"),
        Contact(id = "mtu-cs-025", name = "Jianhui Yue", role = "Associate Professor", department = "Computer Science", email = "jyue@mtu.edu", phone = "906-487-1726", office = "Rekhi Hall 203"),
        Contact(id = "mtu-cs-026", name = "Bo Zhang", role = "Assistant Professor", department = "Computer Science", email = "bo.zhang@mtu.edu", phone = "906-487-2364", office = "Rekhi Hall 307"),
        Contact(id = "mtu-cs-027", name = "Ruihong Zhang", role = "Teaching Professor", department = "Computer Science", email = "ruihong@mtu.edu", phone = "906-487-1638", office = "Rekhi Hall 302"),
        Contact(id = "mtu-ac-001", name = "Dennis Livesay", role = "Dave House Dean of Computing", department = "College of Computing", email = "dlivesay@mtu.edu", phone = "906-487-2316", office = "Rekhi Hall 221"),
        Contact(id = "mtu-ac-002", name = "Daniel R. Fuhrmann", role = "Department Chair & Professor", department = "Applied Computing", email = "fuhrmann@mtu.edu", phone = "906-487-2871", office = "Rekhi Hall 323"),
        Contact(id = "mtu-ac-003", name = "Yu Cai", role = "Associate Dean & Professor", department = "Applied Computing", email = "cai@mtu.edu", phone = "906-487-1471", office = "Rekhi Hall 110"),
        Contact(id = "mtu-ac-004", name = "Todd O. Arney", role = "Associate Teaching Professor & IT Program Director", department = "Applied Computing", email = "toarney@mtu.edu", phone = "906-487-1085", office = "Rekhi Hall 103"),
        Contact(id = "mtu-ac-005", name = "Nader Abu-Alrub", role = "Assistant Teaching Professor", department = "Applied Computing", email = "nabualru@mtu.edu", phone = "906-487-4305", office = "EERC 417"),
        Contact(id = "mtu-ac-006", name = "Nathir A. Rawashdeh", role = "Assistant Professor", department = "Applied Computing", email = "narawash@mtu.edu", phone = "906-487-1611", office = "EERC 411"),
        Contact(id = "mtu-ac-007", name = "Ashraf I. Saleem", role = "Assistant Professor & Mechatronics Co-Director", department = "Applied Computing", email = "ashraf@mtu.edu", phone = "906-487-2384", office = "EERC 412"),
        Contact(id = "mtu-ac-008", name = "Aleksandr Sergeyev", role = "Professor & Grad Program Director", department = "Applied Computing", email = "avsergue@mtu.edu", phone = "906-487-2258", office = "EERC 413"),
        Contact(id = "mtu-ac-009", name = "Tim Van Wagner", role = "Associate Teaching Professor", department = "Applied Computing", email = "tavanwag@mtu.edu", phone = "906-487-2230", office = "Rekhi Hall 108"),
        Contact(id = "mtu-ac-010", name = "Ronghua (Sam) Xu", role = "Assistant Professor", department = "Applied Computing", email = "ronghuax@mtu.edu", phone = "906-487-3386", office = "Rekhi Hall 107"),
        Contact(id = "mtu-ac-011", name = "Yunlong Xing", role = "Assistant Professor", department = "Applied Computing & Computer Science", email = "yuxing@mtu.edu", phone = "906-487-2638", office = "EERC 220"),
        Contact(id = "mtu-ece-001", name = "Wayne W. Weaver", role = "Department Chair & Professor", department = "Electrical and Computer Engineering", email = "wwweaver@mtu.edu", phone = "906-487-1461", office = "EERC 121"),
        Contact(id = "mtu-ece-002", name = "Christopher (Kit) Cischke", role = "Associate Chair & Teaching Professor", department = "Electrical and Computer Engineering", email = "cmcischk@mtu.edu", phone = "906-487-2011", office = "EERC 520"),
        Contact(id = "mtu-ece-003", name = "Aurenice M. Oliveira", role = "Associate Chair & Director of Grad Studies", department = "Electrical and Computer Engineering", email = "oliveira@mtu.edu", phone = "906-487-2494", office = "EERC 234"),
        Contact(id = "mtu-ece-004", name = "Hongyu An", role = "Assistant Professor", department = "Electrical and Computer Engineering", email = "hongyua@mtu.edu", phone = "906-487-3382", office = "EERC 710"),
        Contact(id = "mtu-ece-005", name = "Glen E. Archer", role = "Teaching Professor", department = "Electrical and Computer Engineering", email = "gearcher@mtu.edu", phone = "906-487-2789", office = "EERC 629"),
        Contact(id = "mtu-ece-006", name = "Paul L. Bergstrom", role = "Professor", department = "Electrical and Computer Engineering", email = "paulb@mtu.edu", phone = "906-487-2058", office = "EERC 630"),
        Contact(id = "mtu-ece-007", name = "Jeremy P. Bos", role = "Associate Professor", department = "Electrical and Computer Engineering", email = "jpbos@mtu.edu", phone = "906-487-3161", office = "EERC 236"),
        Contact(id = "mtu-ece-008", name = "Shane Oberloier", role = "Assistant Teaching Professor & Alley Makerspace Director", department = "Electrical and Computer Engineering", email = "swoberlo@mtu.edu", phone = "906-487-2941", office = "EERC 518"),
        Contact(id = "mtu-ece-009", name = "Anthony (Tony) Pinar", role = "Associate Teaching Professor & Senior Design Coordinator", department = "Electrical and Computer Engineering", email = "ajpinar@mtu.edu", phone = "906-487-0024", office = "EERC 731"),
        Contact(id = "mtu-ece-010", name = "Chee-Wooi Ten", role = "Professor", department = "Electrical and Computer Engineering", email = "ten@mtu.edu", phone = "906-487-0397", office = "EERC 612"),
        Contact(id = "mtu-bus-001", name = "Sri Beldona", role = "Dean & Professor of Management", department = "College of Business", email = "sbeldona@mtu.edu", phone = "906-487-2668", office = "Academic Office Building 103"),
        Contact(id = "mtu-bus-002", name = "Manish K. Srivastava", role = "Associate Dean & Professor", department = "College of Business", email = "mksrivas@mtu.edu", phone = "906-487-1991", office = "Academic Office Building 105"),
        Contact(id = "mtu-bus-003", name = "Jonathan Leinonen", role = "Assistant Dean & Teaching Professor", department = "College of Business", email = "jeleinon@mtu.edu", phone = "906-487-2598", office = "Academic Office Building G002"),
        Contact(id = "mtu-bus-004", name = "Ryan Neely", role = "Undergraduate Academic Advisor", department = "College of Business", email = "rmneely@mtu.edu", phone = "906-487-3597", office = "Academic Office Building 108"),
        Contact(id = "mtu-bus-005", name = "Marie Cleveland", role = "Student Success and Outreach Coordinator", department = "College of Business", email = "mlclevel@mtu.edu", phone = "906-487-3055", office = "Academic Office Building 109"),
        Contact(id = "mtu-bus-006", name = "Dean Johnson", role = "Professor of Finance & APMP Director", department = "College of Business", email = "dean@mtu.edu", phone = "906-487-1450", office = "Academic Office Building 115"),
        Contact(id = "mtu-bus-007", name = "Jenny Apriesnig", role = "Associate Professor of Economics", department = "College of Business", email = "jlapries@mtu.edu", phone = "906-487-2223", office = "Academic Office Building 123"),
        Contact(id = "mtu-bus-008", name = "Elham Asgari", role = "Assistant Professor of Management", department = "College of Business", email = "easgari@mtu.edu", phone = "906-487-2803", office = "Academic Office Building 121"),
        Contact(id = "mtu-bus-009", name = "Laura J. Sieders", role = "Assistant Teaching Professor in Accounting", department = "College of Business", email = "ljsieder@mtu.edu", phone = "906-487-3259", office = "Academic Office Building 114"),
        Contact(id = "mtu-bus-010", name = "Jeffrey Wall", role = "Associate Professor of MIS & Analytics", department = "College of Business", email = "jdwall@mtu.edu", phone = "906-487-1707", office = "Academic Office Building G010")
    )
}
