import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable, Comparable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct ProjectTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var details: String
    var dueDate: Date
    var status: TaskStatus
    var priority: TaskPriority
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        dueDate: Date,
        status: TaskStatus = .notStarted,
        priority: TaskPriority = .medium,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.status = status
        self.priority = priority
        self.isArchived = isArchived
    }
}

struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var tasks: [ProjectTask]
    var colorName: String
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        startDate: Date = .now,
        endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now,
        tasks: [ProjectTask] = [],
        colorName: String = "blue",
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.tasks = tasks
        self.colorName = colorName
        self.isArchived = isArchived
    }

    var activeTasks: [ProjectTask] {
        tasks.filter { !$0.isArchived }
    }

    var completionPercentage: Double {
        let active = activeTasks
        guard !active.isEmpty else { return 0 }
        let completed = active.filter { $0.status == .completed }.count
        return Double(completed) / Double(active.count)
    }
}
