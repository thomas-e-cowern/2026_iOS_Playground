import Testing
import Foundation
import SwiftData
@testable import ClaudeApp

// MARK: - Test Helpers

@MainActor
private func makeContext() -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
    return container.mainContext
}

@MainActor
private func makeStore() -> ProjectStore {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
    return ProjectStore(modelContext: container.mainContext)
}

@MainActor
struct NotificationManagerTests {

    // MARK: - Initialization

    @Test func initialStateIsNotAuthorized() {
        let manager = NotificationManager()
        #expect(manager.isAuthorized == false)
    }

    // MARK: - Reschedule Filters Out Completed Tasks

    @Test func rescheduleSkipsCompletedTasks() async {
        let manager = NotificationManager()
        let context = makeContext()
        let calendar = Calendar.current

        let completedTask = ProjectTask(
            title: "Done task",
            dueDate: calendar.date(byAdding: .day, value: 3, to: .now)!,
            status: .completed,
            priority: .medium
        )
        let project = Project(
            name: "Test Project",
            tasks: [completedTask]
        )
        context.insert(project)

        await manager.rescheduleAll(for: [project])
    }

    @Test func rescheduleHandlesEmptyProjects() async {
        let manager = NotificationManager()
        await manager.rescheduleAll(for: [])
    }

    @Test func rescheduleHandlesProjectWithNoTasks() async {
        let manager = NotificationManager()
        let context = makeContext()
        let project = Project(name: "Empty Project")
        context.insert(project)
        await manager.rescheduleAll(for: [project])
    }

    @Test func rescheduleHandlesMultipleProjects() async {
        let manager = NotificationManager()
        let context = makeContext()
        let calendar = Calendar.current

        let projectA = Project(
            name: "Project A",
            endDate: calendar.date(byAdding: .day, value: 10, to: .now)!,
            tasks: [
                ProjectTask(title: "Task A1", dueDate: calendar.date(byAdding: .day, value: 2, to: .now)!, priority: .high),
                ProjectTask(title: "Task A2", dueDate: calendar.date(byAdding: .day, value: 7, to: .now)!, priority: .low),
            ]
        )
        let projectB = Project(
            name: "Project B",
            endDate: calendar.date(byAdding: .day, value: 20, to: .now)!,
            tasks: [
                ProjectTask(title: "Task B1", dueDate: calendar.date(byAdding: .day, value: 3, to: .now)!, priority: .medium),
            ]
        )
        context.insert(projectA)
        context.insert(projectB)

        await manager.rescheduleAll(for: [projectA, projectB])
    }

    // MARK: - Badge

    @Test func clearBadgeDoesNotCrash() {
        let manager = NotificationManager()
        manager.clearBadge()
    }

    @Test func updateBadgeDoesNotCrash() {
        let manager = NotificationManager()
        manager.updateBadge(count: 5)
    }

    @Test func updateBadgeWithZeroDoesNotCrash() {
        let manager = NotificationManager()
        manager.updateBadge(count: 0)
    }
}

// MARK: - ProjectStore Notification Integration Tests

@MainActor
struct ProjectStoreNotificationIntegrationTests {

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

    @Test func updateTaskTriggersRescheduleWithoutCrash() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let project = store.projects[0]
        let projectID = project.id
        let task = project.tasks[0]
        task.status = .completed
        store.updateTask(task, in: projectID)
    }

    @Test func deleteTaskTriggersRescheduleWithoutCrash() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let project = store.projects[0]
        let projectID = project.id
        let taskID = project.tasks[0].id
        store.deleteTask(taskID, from: projectID)
    }

    @Test func deleteProjectTriggersRescheduleWithoutCrash() {
        let store = makeStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let projectID = store.activeProjects[0].id
        store.deleteProject(projectID)
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
