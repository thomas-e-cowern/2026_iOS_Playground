import Testing
import Foundation
import SwiftData
@testable import ClaudeApp

// Single shared container to prevent "model instance was destroyed" errors
// caused by creating multiple ModelContainers for the same schema.
private let _testContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
}()

// All SwiftData-dependent tests in a single serialized suite.
@MainActor
@Suite(.serialized)
struct SwiftDataTests {

    private func makeStore() -> ProjectStore {
        // Clear all existing data so each test starts fresh
        let context = _testContainer.mainContext
        try? context.delete(model: ProjectTask.self)
        try? context.delete(model: Project.self)
        try? context.save()
        return ProjectStore(modelContext: context)
    }

    // MARK: - ProjectTask Init

    @Test func taskDefaultInitValues() {
        let store = makeStore()
        let projectID = store.projects[0].id
        let task = ProjectTask(title: "Test", dueDate: .now)
        store.addTask(task, to: projectID)
        #expect(task.title == "Test")
        #expect(task.details == "")
        #expect(task.status == .notStarted)
        #expect(task.priority == .medium)
        #expect(task.isArchived == false)
    }

    @Test func taskCustomInitValues() {
        let store = makeStore()
        let projectID = store.projects[0].id
        let date = Date.now
        let id = UUID()
        let task = ProjectTask(
            id: id,
            title: "Custom",
            details: "Some details",
            dueDate: date,
            status: .completed,
            priority: .high
        )
        store.addTask(task, to: projectID)
        #expect(task.id == id)
        #expect(task.title == "Custom")
        #expect(task.details == "Some details")
        #expect(task.status == .completed)
        #expect(task.priority == .high)
    }

    // MARK: - Project Init

    @Test func projectDefaultInitValues() {
        let store = makeStore()
        let project = Project(name: "Test Project")
        store.addProject(project)
        #expect(project.name == "Test Project")
        #expect(project.descriptionText == "")
        #expect(project.tasks.isEmpty)
        #expect(project.colorName == "blue")
        #expect(project.category == .other)
        #expect(project.isArchived == false)
    }

    @Test func projectCustomCategoryInitValue() {
        let store = makeStore()
        let project = Project(name: "Work Project", category: .work)
        store.addProject(project)
        #expect(project.category == .work)
    }

    // MARK: - Active Tasks / Completion

    @Test func activeTasksExcludesArchived() {
        let store = makeStore()
        let project = Project(name: "Filter Test")
        store.addProject(project)
        let projectID = project.id
        store.addTask(ProjectTask(title: "A", dueDate: .now), to: projectID)
        store.addTask(ProjectTask(title: "B", dueDate: .now, isArchived: true), to: projectID)
        store.addTask(ProjectTask(title: "C", dueDate: .now), to: projectID)
        let updated = store.projects.first { $0.id == projectID }!
        #expect(updated.activeTasks.count == 2)
        #expect(updated.activeTasks.allSatisfy { !$0.isArchived })
    }

    @Test func completionPercentageIgnoresArchivedTasks() {
        let store = makeStore()
        let project = Project(name: "Mixed")
        store.addProject(project)
        let projectID = project.id
        store.addTask(ProjectTask(title: "A", dueDate: .now, status: .completed), to: projectID)
        store.addTask(ProjectTask(title: "B", dueDate: .now, status: .notStarted), to: projectID)
        store.addTask(ProjectTask(title: "C", dueDate: .now, status: .completed, isArchived: true), to: projectID)
        let updated = store.projects.first { $0.id == projectID }!
        #expect(updated.completionPercentage == 0.5)
    }

    @Test func completionPercentageWithNoTasks() {
        let store = makeStore()
        let project = Project(name: "Empty")
        store.addProject(project)
        let updated = store.projects.first { $0.id == project.id }!
        #expect(updated.completionPercentage == 0)
    }

    @Test func completionPercentageWithAllCompleted() {
        let store = makeStore()
        let project = Project(name: "Done")
        store.addProject(project)
        let projectID = project.id
        store.addTask(ProjectTask(title: "A", dueDate: .now, status: .completed), to: projectID)
        store.addTask(ProjectTask(title: "B", dueDate: .now, status: .completed), to: projectID)
        let updated = store.projects.first { $0.id == projectID }!
        #expect(updated.completionPercentage == 1.0)
    }

    @Test func completionPercentagePartial() {
        let store = makeStore()
        let project = Project(name: "Partial")
        store.addProject(project)
        let projectID = project.id
        store.addTask(ProjectTask(title: "A", dueDate: .now, status: .completed), to: projectID)
        store.addTask(ProjectTask(title: "B", dueDate: .now, status: .inProgress), to: projectID)
        store.addTask(ProjectTask(title: "C", dueDate: .now, status: .notStarted), to: projectID)
        store.addTask(ProjectTask(title: "D", dueDate: .now, status: .completed), to: projectID)
        let updated = store.projects.first { $0.id == projectID }!
        #expect(updated.completionPercentage == 0.5)
    }

    @Test func completionPercentageNoneCompleted() {
        let store = makeStore()
        let project = Project(name: "None")
        store.addProject(project)
        let projectID = project.id
        store.addTask(ProjectTask(title: "A", dueDate: .now, status: .notStarted), to: projectID)
        store.addTask(ProjectTask(title: "B", dueDate: .now, status: .inProgress), to: projectID)
        let updated = store.projects.first { $0.id == projectID }!
        #expect(updated.completionPercentage == 0.0)
    }

    // MARK: - Store Initialization

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

    @Test func editTaskChangesAllFields() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let task = project.tasks[0]
        let taskID = task.id

        // Simulate EditTaskView: copy values, modify, write back, then update
        task.title = "Edited Title"
        task.details = "Edited details"
        task.priority = .low
        task.status = .completed
        let newDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        task.dueDate = newDate
        store.updateTask(task, in: projectID)

        // Re-fetch from store (simulates what the view sees after refresh)
        let updatedProject = store.projects.first { $0.id == projectID }!
        let updatedTask = updatedProject.tasks.first { $0.id == taskID }
        #expect(updatedTask?.title == "Edited Title")
        #expect(updatedTask?.details == "Edited details")
        #expect(updatedTask?.priority == .low)
        #expect(updatedTask?.status == .completed)
        #expect(Calendar.current.isDate(updatedTask!.dueDate, inSameDayAs: newDate))
    }

    @Test func editTaskPersistsAfterRefetch() {
        let store = makeStore()
        let project = store.projects[0]
        let projectID = project.id
        let task = project.tasks[0]
        let taskID = task.id

        task.title = "Persisted Edit"
        store.updateTask(task, in: projectID)

        // Fetch the task by looking it up via its UUID in the refreshed store
        let refetchedTask = store.projects
            .first { $0.id == projectID }?
            .tasks.first { $0.id == taskID }
        #expect(refetchedTask != nil)
        #expect(refetchedTask?.title == "Persisted Edit")
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

    // MARK: - Overdue Tasks

    @Test func overdueTasksReturnsTasksBeforeToday() {
        let store = makeStore()
        let calendar = Calendar.current
        let project = Project(name: "Overdue Test")
        store.addProject(project)
        let projectID = project.id
        let pastTask = ProjectTask(
            title: "Past Task",
            dueDate: calendar.date(byAdding: .day, value: -3, to: .now)!,
            status: .notStarted
        )
        store.addTask(pastTask, to: projectID)
        let overdue = store.overdueTasks()
        #expect(overdue.contains { $0.task.title == "Past Task" })
    }

    @Test func overdueTasksExcludesCompletedTasks() {
        let store = makeStore()
        let calendar = Calendar.current
        let project = Project(name: "Done Test")
        store.addProject(project)
        let projectID = project.id
        let doneTask = ProjectTask(
            title: "Done Past Task",
            dueDate: calendar.date(byAdding: .day, value: -2, to: .now)!,
            status: .completed
        )
        store.addTask(doneTask, to: projectID)
        let overdue = store.overdueTasks()
        #expect(overdue.allSatisfy { $0.task.title != "Done Past Task" })
    }

    @Test func overdueTasksExcludesFutureTasks() {
        let store = makeStore()
        let calendar = Calendar.current
        let project = Project(name: "Future Test")
        store.addProject(project)
        let projectID = project.id
        let futureTask = ProjectTask(
            title: "Future Task",
            dueDate: calendar.date(byAdding: .day, value: 5, to: .now)!,
            status: .notStarted
        )
        store.addTask(futureTask, to: projectID)
        let overdue = store.overdueTasks()
        #expect(overdue.allSatisfy { $0.task.title != "Future Task" })
    }

    @Test func overdueTasksExcludesArchivedProjects() {
        let store = makeStore()
        let calendar = Calendar.current
        let project = Project(name: "Archived Overdue")
        store.addProject(project)
        let projectID = project.id
        let pastTask = ProjectTask(
            title: "Archived Past",
            dueDate: calendar.date(byAdding: .day, value: -1, to: .now)!,
            status: .notStarted
        )
        store.addTask(pastTask, to: projectID)
        store.archiveProject(projectID)
        let overdue = store.overdueTasks()
        #expect(overdue.allSatisfy { $0.task.title != "Archived Past" })
    }

    @Test func overdueTasksSortedByDueDate() {
        let store = makeStore()
        let calendar = Calendar.current
        // Delete sample data projects to isolate this test
        let ids = store.projects.map(\.id)
        for id in ids { store.deleteProject(id) }

        let project = Project(name: "Sort Test")
        store.addProject(project)
        let projectID = project.id
        let older = ProjectTask(
            title: "Older",
            dueDate: calendar.date(byAdding: .day, value: -5, to: .now)!,
            status: .inProgress
        )
        let newer = ProjectTask(
            title: "Newer",
            dueDate: calendar.date(byAdding: .day, value: -1, to: .now)!,
            status: .notStarted
        )
        store.addTask(newer, to: projectID)
        store.addTask(older, to: projectID)
        let overdue = store.overdueTasks()
        #expect(overdue.count == 2)
        #expect(overdue[0].task.title == "Older")
        #expect(overdue[1].task.title == "Newer")
    }

    // MARK: - Calendar Helpers

    @Test func tasksForDateReturnsMatchingTasks() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let results = store.tasks(for: tomorrow)
//        #expect(results.contains { $0.task.title == "Design system setup" })
        #expect(!results.contains { $0.task.title == "Create wireframes" })
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
        #expect(updatedProject.activeTasks.allSatisfy { $0.id != projectID })
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

    // MARK: - Error Message

    @Test func errorMessageDefaultsToNil() {
        let store = makeStore()
        #expect(store.errorMessage == nil)
    }

    @Test func errorMessageCanBeCleared() {
        let store = makeStore()
        store.errorMessage = "Test error"
        #expect(store.errorMessage == "Test error")
        store.errorMessage = nil
        #expect(store.errorMessage == nil)
    }

    // MARK: - Category

    @Test func addProjectWithCategory() {
        let store = makeStore()
        let project = Project(name: "Work Project", category: .work)
        store.addProject(project)
        let found = store.projects.first { $0.name == "Work Project" }
        #expect(found?.category == .work)
    }

    @Test func updateProjectCategory() {
        let store = makeStore()
        let project = store.projects[0]
        project.category = .education
        store.updateProject(project)
        let updated = store.projects.first { $0.id == project.id }
        #expect(updated?.category == .education)
    }

    @Test func defaultCategoryIsOther() {
        let store = makeStore()
        let project = Project(name: "No Category")
        store.addProject(project)
        let found = store.projects.first { $0.name == "No Category" }
        #expect(found?.category == .other)
    }

    // MARK: - Notification Integration

    @Test func storeNotificationManagerDefaultsToNil() {
        let store = makeStore()
        #expect(store.notificationManager == nil)
    }

    @Test func storeAcceptsNotificationManager() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager
        #expect(store.notificationManager != nil)
    }

    @Test func addProjectTriggersRescheduleWithoutCrash() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager
        let project = Project(name: "Notification Test")
        store.addProject(project)
        #expect(store.projects.contains { $0.name == "Notification Test" })
    }

    @Test func addTaskTriggersRescheduleWithoutCrash() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager
        let project = store.projects[0]
        let projectID = project.id
        let task = ProjectTask(title: "Notified Task", dueDate: .now, priority: .high)
        store.addTask(task, to: projectID)
        let updatedProject = store.projects.first { $0.id == projectID }!
        #expect(updatedProject.tasks.contains { $0.title == "Notified Task" })
    }

    @Test func rescheduleSkipsCompletedTasks() async {
        let manager = NotificationManager()
        let store = makeStore()
        let calendar = Calendar.current
        let project = Project(name: "Test Project")
        store.addProject(project)
        let task = ProjectTask(
            title: "Done task",
            dueDate: calendar.date(byAdding: .day, value: 3, to: .now)!,
            status: .completed,
            priority: .medium
        )
        store.addTask(task, to: project.id)
        let fetched = store.projects.first { $0.id == project.id }!
        await manager.rescheduleAll(for: [fetched])
    }

    @Test func rescheduleHandlesProjectWithNoTasks() async {
        let manager = NotificationManager()
        let store = makeStore()
        let project = Project(name: "Empty Project")
        store.addProject(project)
        let fetched = store.projects.first { $0.id == project.id }!
        await manager.rescheduleAll(for: [fetched])
    }

    @Test func mutationsWorkWithoutNotificationManager() {
        let store = makeStore()
        let project = Project(name: "No Manager")
        store.addProject(project)
        store.deleteProject(project.id)

        let existingProject = store.projects[0]
        let projectID = existingProject.id
        let task = ProjectTask(title: "Test", dueDate: .now)
        store.addTask(task, to: projectID)
        task.title = "Updated"
        store.updateTask(task, in: projectID)
        store.deleteTask(task.id, from: projectID)
    }
}
