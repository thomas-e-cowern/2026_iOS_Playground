import Foundation
import Observation

@Observable
final class ProjectStore {
    var projects: [Project] = []

    init() {
        // Seed with example data
        let sample = Project(name: "Sample Project", notes: "Demo notes", tasks: [
            TaskItem(title: "Set up repo"),
            TaskItem(title: "Plan milestones", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
        ])
        projects = [sample]
    }

    // MARK: - Project CRUD
    func addProject(name: String, notes: String = "", dueDate: Date? = nil) {
        projects.append(Project(name: name, notes: notes, dueDate: dueDate))
    }

    func updateProject(_ project: Project, name: String, notes: String) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[idx].name = name
        projects[idx].notes = notes
    }

    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
    }

    func archiveProject(_ project: Project, archived: Bool) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[idx].isArchived = archived
    }

    // MARK: - Tasks
    func addTask(to project: Project, title: String, dueDate: Date? = nil) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        let task = TaskItem(title: title, dueDate: dueDate)
        projects[idx].tasks.append(task)
    }

    func toggleTask(_ task: TaskItem) {
        for pIdx in projects.indices {
            if let tIdx = projects[pIdx].tasks.firstIndex(where: { $0.id == task.id }) {
                projects[pIdx].tasks[tIdx].isCompleted.toggle()
                break
            }
        }
    }

    func deleteTask(_ task: TaskItem) {
        for pIdx in projects.indices {
            if let tIdx = projects[pIdx].tasks.firstIndex(where: { $0.id == task.id }) {
                projects[pIdx].tasks.remove(at: tIdx)
                break
            }
        }
    }

    func archiveTask(_ task: TaskItem, archived: Bool) {
        for pIdx in projects.indices {
            if let tIdx = projects[pIdx].tasks.firstIndex(where: { $0.id == task.id }) {
                projects[pIdx].tasks[tIdx].isArchived = archived
                break
            }
        }
    }

    // MARK: - Queries
    func tasks(on date: Date) -> [TaskItem] {
        let cal = Calendar.current
        return projects.flatMap { $0.tasks }.filter { task in
            guard let d = task.dueDate else { return false }
            return cal.isDate(d, inSameDayAs: date)
        }
    }
}

