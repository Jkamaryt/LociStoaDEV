import Foundation
import Combine

struct ToDoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var priority = String()
    var classes = String()
    var description = String()
    var dueDate = Date()
    var isCompleted: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, priority, classes, description, dueDate, isCompleted
    }
    
    init(
        id: UUID = UUID(),
        priority: String = "",
        classes: String = "",
        description: String = "",
        dueDate: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.priority = priority
        self.classes = classes
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        priority = try container.decodeIfPresent(String.self, forKey: .priority) ?? ""
        classes = try container.decodeIfPresent(String.self, forKey: .classes) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date()
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}

class ToDoList: ObservableObject {
    @Published var items: [ToDoItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "data")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "data") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ToDoItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        items = []
    }
}
