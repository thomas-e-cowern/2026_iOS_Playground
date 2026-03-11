import Testing
import Foundation
import SwiftData
@testable import ClaudeApp

// MARK: - ProjectStore Tests

@MainActor
struct ProjectStoreTests {

    private func makeStore() -> ProjectStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
        return ProjectStore(modelContext: container.mainContext)
    }

    // MARK: - Initialization

    @Test func initLoadsSampleData() {
        let store = makeStore()
        #expect(store.projects.count == 3)
    }

    @Test func sampleProjectsHaveTasks() {
        let store = makeStore()
        for project in store.projects {
            #expect(!project.tasks.isEmpty)
        }
    }

    // MARK: - Add Project

    @Test func addProjectIncreasesCount() {
        let store = makeStore()
        let initialCount = store.projects.count
        let project = Project(name: "New Project")
        store.addProject(project)
        #expect(store.projects.count == initialCount + 1)
    }

    @Test func addProjectAppendsCorrectly() {
        let store = makeStore()
        let project = Project(name: "Appended")
        store.addProject(project)
        #expect(store.projects.contains { $0.name == "Appended" })
    }

    // MARK: - Delete Project

    @Test func deleteProjectRemovesCorrectProject() {
        let store = makeStore()
        let firstProject = store.activeProjects[0]
        let firstProjectID = firstProject.id
        store.deleteProject(firstProjectID)
        #expect(store.projects.allSatisfy { $0.id != firstProjectID })
    }

    @Test func deleteProjectDecreasesCount() {
        let store = makeStore()
        let initialCount = store.projects.count
        let projectID = store.projects[0].id
        store.deleteProject(projectID)
        #expect(store.projects.count == initialCount - 1)
    }

    // MARK: - Add Task

    @Test func addTaskToProject() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let initialTaskCount = project.tasks.count
        let task = ProjectTask(title: "New Task", dueDate: .now)
        store.addTask(task, to: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.count == initialTaskCount + 1)
        #expect(updatedProject.tasks.contains { $0.title == "New Task" })
    }

    @Test func addTaskToInvalidProjectDoesNothing() {
        let store = makeStore()
        let bogusID = UUID()
        let task = ProjectTask(title: "Orphan", dueDate: .now)
        store.addTask(task, to: bogusID)
        for project in store.projects {
            #expect(project.tasks.allSatisfy { $0.title != "Orphan" })
        }
    }

    // MARK: - Update Task

    @Test func updateTaskChangesStatus() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let task = project.tasks[0]
        let originalStatus = task.status
        task.status = (originalStatus == .completed) ? .notStarted : .completed
        store.updateTask(task, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        let updatedTask = updatedProject.tasks.first { $0.id == task.id }
        #expect(updatedTask?.status != originalStatus)
    }

    @Test func updateTaskChangesTitle() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let task = project.tasks[0]
        task.title = "Updated Title"
        store.updateTask(task, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        let updatedTask = updatedProject.tasks.first { $0.id == task.id }
        #expect(updatedTask?.title == "Updated Title")
    }

    // MARK: - Delete Task

    @Test func deleteTaskRemovesFromProject() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        let initialCount = project.tasks.count
        store.deleteTask(taskID, from: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.count == initialCount - 1)
        #expect(updatedProject.tasks.allSatisfy { $0.id != taskID })
    }

    @Test func deleteTaskWithInvalidProjectDoesNothing() {
        let store = makeStore()
        let taskID = store.projects[0].tasks[0].id
        let initialCount = store.projects[0].tasks.count
        store.deleteTask(taskID, from: UUID())
        #expect(store.projects[0].tasks.count == initialCount)
    }

    @Test func deleteTaskWithInvalidTaskIDDoesNothing() {
        let store = makeStore()
        let projectID = store.projects[0].id
        let initialCount = store.projects[0].tasks.count
        store.deleteTask(UUID(), from: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.count == initialCount)
    }

    // MARK: - Calendar Helpers

    @Test func tasksForDateReturnsMatchingTasks() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let results = store.tasks(for: tomorrow)
        #expect(results.contains { $0.task.title == "Create wireframes" })
    }

    @Test func tasksForDateWithNoTasksReturnsEmpty() {
        let store = makeStore()
        let calendar = Calendar.current
        let farFuture = calendar.date(byAdding: .year, value: 10, to: .now)!
        let results = store.tasks(for: farFuture)
        #expect(results.isEmpty)
    }

    @Test func tasksForDateReturnsCorrectProjectAssociation() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let results = store.tasks(for: tomorrow)
        for result in results {
            #expect(result.project.tasks.contains { $0.id == result.task.id })
        }
    }

    @Test func allTasksReturnsFlattenedList() {
        let store = makeStore()
        let totalTasks = store.activeProjects.reduce(0) { $0 + $1.activeTasks.count }
        let allTasks = store.allTasks()
        #expect(allTasks.count == totalTasks)
    }

    @Test func allTasksAssociatesCorrectProjects() {
        let store = makeStore()
        let allTasks = store.allTasks()
        for item in allTasks {
            #expect(item.project.tasks.contains { $0.id == item.task.id })
        }
    }

    // MARK: - Update Project

    @Test func updateProjectChangesName() {
        let store = makeStore()
        let project = store.projects[0]
        project.name = "Renamed"
        store.updateProject(project)
        #expect(store.projects.contains { $0.name == "Renamed" })
    }

    // MARK: - Delete Project by ID

    @Test func deleteProjectByIDRemovesProject() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.deleteProject(projectID)
        #expect(store.projects.allSatisfy { $0.id != projectID })
    }

    @Test func deleteProjectByInvalidIDDoesNothing() {
        let store = makeStore()
        let initialCount = store.projects.count
        store.deleteProject(UUID())
        #expect(store.projects.count == initialCount)
    }

    // MARK: - Archive Project

    @Test func archiveProjectSetsIsArchived() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.projects.first(where: { $0.id == projectID })?.isArchived == true)
    }

    @Test func archivedProjectExcludedFromActiveProjects() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.activeProjects.allSatisfy { $0.id != projectID })
    }

    @Test func archivedProjectAppearsInArchivedProjects() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.archivedProjects.contains { $0.id == projectID })
    }

    @Test func unarchiveProjectRestoresProject() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.archiveProject(projectID)
        #expect(store.activeProjects.allSatisfy { $0.id != projectID })
        store.unarchiveProject(projectID)
        #expect(store.activeProjects.contains { $0.id == projectID })
        #expect(store.projects.first(where: { $0.id == projectID })?.isArchived == false)
    }

    @Test func archiveInvalidProjectDoesNothing() {
        let store = makeStore()
        store.archiveProject(UUID())
        #expect(store.projects.allSatisfy { !$0.isArchived })
    }

    // MARK: - Archive Task

    @Test func archiveTaskSetsIsArchived() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        store.archiveTask(taskID, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.first(where: { $0.id == taskID })?.isArchived == true)
    }

    @Test func archivedTaskExcludedFromActiveTasks() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        store.archiveTask(taskID, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.activeTasks.allSatisfy { $0.id != taskID })
    }

    @Test func unarchiveTaskRestoresTask() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        store.archiveTask(taskID, in: projectID)
        store.unarchiveTask(taskID, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.activeTasks.contains { $0.id == taskID })
    }

    @Test func archiveTaskInvalidProjectDoesNothing() {
        let store = makeStore()
        let taskID = store.projects[0].tasks[0].id
        store.archiveTask(taskID, in: UUID())
        #expect(store.projects[0].tasks.first(where: { $0.id == taskID })?.isArchived == false)
    }

    @Test func archiveTaskInvalidTaskDoesNothing() {
        let store = makeStore()
        let projectID = store.projects[0].id
        store.archiveTask(UUID(), in: projectID)
        #expect(store.projects[0].tasks.allSatisfy { !$0.isArchived })
    }

    // MARK: - Completed Projects

    @Test func completedProjectsListsFullyComplete() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        for task in project.tasks {
            task.status = .completed
            store.updateTask(task, in: projectID)
        }
        #expect(store.completedProjects.contains { $0.id == projectID })
    }

    @Test func completedProjectsExcludesArchivedProjects() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        for task in project.tasks {
            task.status = .completed
            store.updateTask(task, in: projectID)
        }
        store.archiveProject(projectID)
        #expect(store.completedProjects.allSatisfy { $0.id != projectID })
    }

    // MARK: - Calendar Helpers Exclude Archived

    @Test func tasksForDateExcludesArchivedProjects() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let projectID = store.projects.first(where: { $0.name == "App Redesign" })!.id
        store.archiveProject(projectID)
        let results = store.tasks(for: tomorrow)
        #expect(results.allSatisfy { $0.project.id != projectID })
    }

    @Test func tasksForDateExcludesArchivedTasks() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let project = store.projects.first(where: { $0.name == "App Redesign" })!
        let projectID = project.id
        let taskID = project.tasks.first(where: { $0.title == "Create wireframes" })!.id
        store.archiveTask(taskID, in: projectID)
        let results = store.tasks(for: tomorrow)
        #expect(results.allSatisfy { $0.task.id != taskID })
    }

    @Test func allTasksExcludesArchivedItems() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        let initialCount = store.allTasks().count
        store.archiveTask(taskID, in: projectID)
        #expect(store.allTasks().count == initialCount - 1)
    }

    // MARK: - Integration Scenarios

    @Test func addThenDeleteTask() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let initialCount = project.tasks.count
        let task = ProjectTask(title: "Temporary", dueDate: .now)
        store.addTask(task, to: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.count == initialCount + 1)
        store.deleteTask(task.id, from: projectID)
        let finalProject = store.projects.first { $0.id == projectID }!
        #expect(finalProject.tasks.count == initialCount)
    }

    @Test func addThenUpdateTask() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let task = ProjectTask(title: "Original", dueDate: .now, priority: .low)
        store.addTask(task, to: projectID)
        task.title = "Modified"
        task.priority = .high
        store.updateTask(task, in: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        let updated = updatedProject.tasks.first { $0.id == task.id }
        #expect(updated?.title == "Modified")
        #expect(updated?.priority == .high)
    }

    @Test func deleteAllProjectsLeavesEmpty() {
        let store = makeStore()
        let projectIDs = store.projects.map(\.id)
        for id in projectIDs {
            store.deleteProject(id)
        }
        #expect(store.projects.isEmpty)
        #expect(store.allTasks().isEmpty)
    }
}
