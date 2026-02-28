import Foundation

struct Project: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var notes: String = ""
    var createdAt: Date = Date()
    var dueDate: Date? = nil
    var tasks: [TaskItem] = []
}

struct TaskItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var detail: String = ""
    var dueDate: Date? = nil
    var isCompleted: Bool = false
    var estimatedMinutes: Int? = nil
    var projectID: UUID
}

final class AppStore: ObservableObject {
    @Published var projects: [Project] = []

    func addProject(name: String, notes: String = "", dueDate: Date? = nil) {
        let project = Project(name: name, notes: notes, dueDate: dueDate, tasks: [])
        projects.append(project)
    }

    func addTask(to projectID: UUID, title: String, detail: String = "", dueDate: Date? = nil, estimatedMinutes: Int? = nil) {
        guard let idx = projects.firstIndex(where: { $0.id == projectID }) else { return }
        let task = TaskItem(title: title, detail: detail, dueDate: dueDate, isCompleted: false, estimatedMinutes: estimatedMinutes, projectID: projectID)
        projects[idx].tasks.append(task)
    }

    func toggleTask(_ taskID: UUID, in projectID: UUID) {
        guard let pIdx = projects.firstIndex(where: { $0.id == projectID }) else { return }
        guard let tIdx = projects[pIdx].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        projects[pIdx].tasks[tIdx].isCompleted.toggle()
    }

    func tasks(on date: Date) -> [TaskItem] {
        projects.flatMap { $0.tasks }.filter { task in
            guard let d = task.dueDate else { return false }
            return Calendar.current.isDate(d, inSameDayAs: date)
        }
    }
}
