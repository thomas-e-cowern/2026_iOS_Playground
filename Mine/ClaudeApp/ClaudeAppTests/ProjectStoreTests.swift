import Testing
import Foundation
@testable import ClaudeApp

// MARK: - ProjectStore Tests

@MainActor
struct ProjectStoreTests {

    // MARK: - Initialization

    @Test func initLoadsSampleData() {
        let store = ProjectStore()
        #expect(store.projects.count == 3)
    }

    @Test func sampleProjectsHaveTasks() {
        let store = ProjectStore()
        for project in store.projects {
            #expect(!project.tasks.isEmpty)
        }
    }

    // MARK: - Add Project

    @Test func addProjectIncreasesCount() {
        let store = ProjectStore()
        let initialCount = store.projects.count
        let project = Project(name: "New Project")
        store.addProject(project)
        #expect(store.projects.count == initialCount + 1)
    }

    @Test func addProjectAppendsToEnd() {
        let store = ProjectStore()
        let project = Project(name: "Appended")
        store.addProject(project)
        #expect(store.projects.last?.name == "Appended")
    }

    // MARK: - Delete Project

    @Test func deleteProjectRemovesCorrectProject() {
        let store = ProjectStore()
        let firstProjectID = store.projects[0].id
        store.deleteProject(at: IndexSet(integer: 0))
        #expect(store.projects.first?.id != firstProjectID)
    }

    @Test func deleteProjectDecreasesCount() {
        let store = ProjectStore()
        let initialCount = store.projects.count
        store.deleteProject(at: IndexSet(integer: 0))
        #expect(store.projects.count == initialCount - 1)
    }

    // MARK: - Add Task

    @Test func addTaskToProject() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let initialTaskCount = store.projects[0].tasks.count
        let task = ProjectTask(title: "New Task", dueDate: .now)
        store.addTask(task, to: projectID)
        #expect(store.projects[0].tasks.count == initialTaskCount + 1)
        #expect(store.projects[0].tasks.last?.title == "New Task")
    }

    @Test func addTaskToInvalidProjectDoesNothing() {
        let store = ProjectStore()
        let bogusID = UUID()
        let task = ProjectTask(title: "Orphan", dueDate: .now)
        store.addTask(task, to: bogusID)
        // No crash, no change to existing projects
        for project in store.projects {
            #expect(project.tasks.allSatisfy { $0.title != "Orphan" })
        }
    }

    // MARK: - Update Task

    @Test func updateTaskChangesStatus() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        var task = store.projects[0].tasks[0]
        let originalStatus = task.status
        task.status = (originalStatus == .completed) ? .notStarted : .completed
        store.updateTask(task, in: projectID)
        let updatedTask = store.projects[0].tasks.first { $0.id == task.id }
        #expect(updatedTask?.status != originalStatus)
    }

    @Test func updateTaskChangesTitle() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        var task = store.projects[0].tasks[0]
        task.title = "Updated Title"
        store.updateTask(task, in: projectID)
        let updatedTask = store.projects[0].tasks.first { $0.id == task.id }
        #expect(updatedTask?.title == "Updated Title")
    }

    @Test func updateTaskWithInvalidProjectDoesNothing() {
        let store = ProjectStore()
        var task = store.projects[0].tasks[0]
        let originalTitle = task.title
        task.title = "Should Not Apply"
        store.updateTask(task, in: UUID())
        #expect(store.projects[0].tasks[0].title == originalTitle)
    }

    @Test func updateTaskWithInvalidTaskIDDoesNothing() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let task = ProjectTask(id: UUID(), title: "Ghost", dueDate: .now)
        store.updateTask(task, in: projectID)
        #expect(store.projects[0].tasks.allSatisfy { $0.title != "Ghost" })
    }

    // MARK: - Delete Task

    @Test func deleteTaskRemovesFromProject() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        let initialCount = store.projects[0].tasks.count
        store.deleteTask(taskID, from: projectID)
        #expect(store.projects[0].tasks.count == initialCount - 1)
        #expect(store.projects[0].tasks.allSatisfy { $0.id != taskID })
    }

    @Test func deleteTaskWithInvalidProjectDoesNothing() {
        let store = ProjectStore()
        let taskID = store.projects[0].tasks[0].id
        let initialCount = store.projects[0].tasks.count
        store.deleteTask(taskID, from: UUID())
        #expect(store.projects[0].tasks.count == initialCount)
    }

    @Test func deleteTaskWithInvalidTaskIDDoesNothing() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let initialCount = store.projects[0].tasks.count
        store.deleteTask(UUID(), from: projectID)
        #expect(store.projects[0].tasks.count == initialCount)
    }

    // MARK: - Calendar Helpers

    @Test func tasksForDateReturnsMatchingTasks() {
        let store = ProjectStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let results = store.tasks(for: tomorrow)
        // The sample data has a task due tomorrow ("Create wireframes")
        #expect(results.contains { $0.task.title == "Create wireframes" })
    }

    @Test func tasksForDateWithNoTasksReturnsEmpty() {
        let store = ProjectStore()
        let calendar = Calendar.current
        // A date far in the future should have no tasks
        let farFuture = calendar.date(byAdding: .year, value: 10, to: .now)!
        let results = store.tasks(for: farFuture)
        #expect(results.isEmpty)
    }

    @Test func tasksForDateReturnsCorrectProjectAssociation() {
        let store = ProjectStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let results = store.tasks(for: tomorrow)
        for result in results {
            // Each returned task should actually belong to the associated project
            #expect(result.project.tasks.contains { $0.id == result.task.id })
        }
    }

    @Test func allTasksReturnsFlattenedList() {
        let store = ProjectStore()
        let totalTasks = store.projects.reduce(0) { $0 + $1.tasks.count }
        let allTasks = store.allTasks()
        #expect(allTasks.count == totalTasks)
    }

    @Test func allTasksAssociatesCorrectProjects() {
        let store = ProjectStore()
        let allTasks = store.allTasks()
        for item in allTasks {
            #expect(item.project.tasks.contains { $0.id == item.task.id })
        }
    }

    // MARK: - Integration Scenarios

    @Test func addThenDeleteTask() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let initialCount = store.projects[0].tasks.count
        let task = ProjectTask(title: "Temporary", dueDate: .now)
        store.addTask(task, to: projectID)
        #expect(store.projects[0].tasks.count == initialCount + 1)
        store.deleteTask(task.id, from: projectID)
        #expect(store.projects[0].tasks.count == initialCount)
    }

    @Test func addThenUpdateTask() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        var task = ProjectTask(title: "Original", dueDate: .now, priority: .low)
        store.addTask(task, to: projectID)
        task.title = "Modified"
        task.priority = .high
        store.updateTask(task, in: projectID)
        let updated = store.projects[0].tasks.first { $0.id == task.id }
        #expect(updated?.title == "Modified")
        #expect(updated?.priority == .high)
    }

    @Test func deleteAllProjectsLeavesEmpty() {
        let store = ProjectStore()
        while !store.projects.isEmpty {
            store.deleteProject(at: IndexSet(integer: 0))
        }
        #expect(store.projects.isEmpty)
        #expect(store.allTasks().isEmpty)
    }
}
