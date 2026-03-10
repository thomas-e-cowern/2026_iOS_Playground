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

    // MARK: - Update Project

    @Test func updateProjectChangesName() {
        let store = ProjectStore()
        var project = store.projects[0]
        project.name = "Renamed"
        store.updateProject(project)
        #expect(store.projects[0].name == "Renamed")
    }

    @Test func updateProjectWithInvalidIDDoesNothing() {
        let store = ProjectStore()
        let fake = Project(id: UUID(), name: "Ghost")
        store.updateProject(fake)
        #expect(store.projects.allSatisfy { $0.name != "Ghost" })
    }

    // MARK: - Delete Project by ID

    @Test func deleteProjectByIDRemovesProject() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.deleteProject(projectID)
        #expect(store.projects.allSatisfy { $0.id != projectID })
    }

    @Test func deleteProjectByInvalidIDDoesNothing() {
        let store = ProjectStore()
        let initialCount = store.projects.count
        store.deleteProject(UUID())
        #expect(store.projects.count == initialCount)
    }

    // MARK: - Archive Project

    @Test func archiveProjectSetsIsArchived() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.projects.first(where: { $0.id == projectID })?.isArchived == true)
    }

    @Test func archivedProjectExcludedFromActiveProjects() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.activeProjects.allSatisfy { $0.id != projectID })
    }

    @Test func archivedProjectAppearsInArchivedProjects() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.archivedProjects.contains { $0.id == projectID })
    }

    @Test func unarchiveProjectRestoresProject() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.activeProjects.allSatisfy { $0.id != projectID })
        store.unarchiveProject(projectID)
        #expect(store.activeProjects.contains { $0.id == projectID })
        #expect(store.projects.first(where: { $0.id == projectID })?.isArchived == false)
    }

    @Test func archiveInvalidProjectDoesNothing() {
        let store = ProjectStore()
        store.archiveProject(UUID())
        #expect(store.projects.allSatisfy { !$0.isArchived })
    }

    // MARK: - Archive Task

    @Test func archiveTaskSetsIsArchived() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: projectID)
        #expect(store.projects[0].tasks.first(where: { $0.id == taskID })?.isArchived == true)
    }

    @Test func archivedTaskExcludedFromActiveTasks() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: projectID)
        #expect(store.projects[0].activeTasks.allSatisfy { $0.id != taskID })
    }

    @Test func unarchiveTaskRestoresTask() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: projectID)
        #expect(store.projects[0].activeTasks.allSatisfy { $0.id != taskID })
        store.unarchiveTask(taskID, in: projectID)
        #expect(store.projects[0].activeTasks.contains { $0.id == taskID })
    }

    @Test func archiveTaskInvalidProjectDoesNothing() {
        let store = ProjectStore()
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: UUID())
        #expect(store.projects[0].tasks.first(where: { $0.id == taskID })?.isArchived == false)
    }

    @Test func archiveTaskInvalidTaskDoesNothing() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        store.archiveTask(UUID(), in: projectID)
        #expect(store.projects[0].tasks.allSatisfy { !$0.isArchived })
    }

    // MARK: - Completed Projects

    @Test func completedProjectsListsFullyComplete() {
        let store = ProjectStore()
        // Complete all tasks in the first project
        let projectID = store.projects[0].id
        for task in store.projects[0].tasks {
            var updated = task
            updated.status = .completed
            store.updateTask(updated, in: projectID)
        }
        #expect(store.completedProjects.contains { $0.id == projectID })
    }

    @Test func completedProjectsExcludesArchivedProjects() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        for task in store.projects[0].tasks {
            var updated = task
            updated.status = .completed
            store.updateTask(updated, in: projectID)
        }
        store.archiveProject(projectID)
        #expect(store.completedProjects.allSatisfy { $0.id != projectID })
    }

    // MARK: - Calendar Helpers Exclude Archived

    @Test func tasksForDateExcludesArchivedProjects() {
        let store = ProjectStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        // Archive the project that has the "Create wireframes" task
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        let results = store.tasks(for: tomorrow)
        #expect(results.allSatisfy { $0.project.id != projectID })
    }

    @Test func tasksForDateExcludesArchivedTasks() {
        let store = ProjectStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: projectID)
        let results = store.tasks(for: tomorrow)
        #expect(results.allSatisfy { $0.task.id != taskID })
    }

    @Test func allTasksExcludesArchivedItems() {
        let store = ProjectStore()
        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        let initialCount = store.allTasks().count
        store.archiveTask(taskID, in: projectID)
        #expect(store.allTasks().count == initialCount - 1)
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
