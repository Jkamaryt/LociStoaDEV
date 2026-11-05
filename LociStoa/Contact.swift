import Foundation

struct Contact: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let role: String          // e.g., "Professor", "Academic Advisor", "Department Chair"
    let department: String    // e.g., "Computer Science", "Registrar", "Financial Aid"
    let email: String
    let phone: String
    let office: String?       // e.g., "Tech Building Rm 304"
}
