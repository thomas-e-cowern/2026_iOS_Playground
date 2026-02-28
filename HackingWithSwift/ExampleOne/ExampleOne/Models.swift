import Foundation
import SwiftData
import Observation

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String
    var createdAt: Date
    var dueDate: Date?
    var isArchived: Bool
    var tasks: [TaskItem]

    init(id: UUID = UUID(), name: String, notes: String = "", createdAt: Date = Date(), dueDate: Date? = nil, isArchived: Bool = false, tasks: [TaskItem] = []) {
        self.id = id
        self.name = name
        self.notes = notes
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.isArchived = isArchived
        self.tasks = tasks
    }
}

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var detail: String
    var dueDate: Date?
    var isCompleted: Bool
    var isArchived: Bool
    var estimatedMinutes: Int?
    var project: Project?

    init(id: UUID = UUID(), title: String, detail: String = "", dueDate: Date? = nil, isCompleted: Bool = false, isArchived: Bool = false, estimatedMinutes: Int? = nil, project: Project? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.isArchived = isArchived
        self.estimatedMinutes = estimatedMinutes
        self.project = project
    }
}

@Observable
final class AppStore {
    var context: ModelContext

    // Cache for simple reactive lists (optional for views that don't use @Query)
    var projects: [Project] = []

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        let fetch = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        projects = (try? context.fetch(fetch)) ?? []
    }

    // MARK: - Project APIs
    @discardableResult
    func addProject(name: String, notes: String = "", dueDate: Date? = nil) -> Project {
        let project = Project(name: name, notes: notes, dueDate: dueDate)
        context.insert(project)
        try? context.save()
        refresh()
        return project
    }

    func deleteProject(_ project: Project) {
        context.delete(project)
        try? context.save()
        refresh()
    }

    // MARK: - Task APIs
    func addTask(to project: Project, title: String, detail: String = "", dueDate: Date? = nil, estimatedMinutes: Int? = nil) {
        let task = TaskItem(title: title, detail: detail, dueDate: dueDate, isCompleted: false, estimatedMinutes: estimatedMinutes, project: project)
        project.tasks.append(task)
        context.insert(task)
        try? context.save()
        refresh()
    }

    func toggleTask(_ task: TaskItem) {
        task.isCompleted.toggle()
        try? context.save()
        refresh()
    }

    func tasks(on date: Date) -> [TaskItem] {
        let fetch = FetchDescriptor<TaskItem>(predicate: #Predicate { task in
            if let d = task.dueDate {
                // Note: SwiftData predicates don't allow calling Calendar; filter post-fetch instead.
                return true
            } else {
                return false
            }
        })
        let candidates = (try? context.fetch(fetch)) ?? []
        return candidates.filter { t in
            if let d = t.dueDate { return Calendar.current.isDate(d, inSameDayAs: date) }
            return false
        }
    }
}

