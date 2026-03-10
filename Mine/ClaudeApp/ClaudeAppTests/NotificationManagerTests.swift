import Testing
import Foundation
@testable import ClaudeApp

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

        // Should not crash even when not authorized — just silently skips
        await manager.rescheduleAll(for: [project])
    }

    @Test func rescheduleHandlesEmptyProjects() async {
        let manager = NotificationManager()
        await manager.rescheduleAll(for: [])
    }

    @Test func rescheduleHandlesProjectWithNoTasks() async {
        let manager = NotificationManager()
        let project = Project(name: "Empty Project")
        await manager.rescheduleAll(for: [project])
    }

    @Test func rescheduleHandlesMultipleProjects() async {
        let manager = NotificationManager()
        let calendar = Calendar.current

        let projects = [
            Project(
                name: "Project A",
                endDate: calendar.date(byAdding: .day, value: 10, to: .now)!,
                tasks: [
                    ProjectTask(title: "Task A1", dueDate: calendar.date(byAdding: .day, value: 2, to: .now)!, priority: .high),
                    ProjectTask(title: "Task A2", dueDate: calendar.date(byAdding: .day, value: 7, to: .now)!, priority: .low),
                ]
            ),
            Project(
                name: "Project B",
                endDate: calendar.date(byAdding: .day, value: 20, to: .now)!,
                tasks: [
                    ProjectTask(title: "Task B1", dueDate: calendar.date(byAdding: .day, value: 3, to: .now)!, priority: .medium),
                ]
            ),
        ]

        await manager.rescheduleAll(for: projects)
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
        let store = ProjectStore()
        #expect(store.notificationManager == nil)
    }

    @Test func storeAcceptsNotificationManager() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager
        #expect(store.notificationManager != nil)
    }

    @Test func addProjectTriggersRescheduleWithoutCrash() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let project = Project(name: "Notification Test")
        store.addProject(project)
        #expect(store.projects.last?.name == "Notification Test")
    }

    @Test func addTaskTriggersRescheduleWithoutCrash() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let projectID = store.projects[0].id
        let task = ProjectTask(title: "Notified Task", dueDate: .now, priority: .high)
        store.addTask(task, to: projectID)
        #expect(store.projects[0].tasks.last?.title == "Notified Task")
    }

    @Test func updateTaskTriggersRescheduleWithoutCrash() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let projectID = store.projects[0].id
        var task = store.projects[0].tasks[0]
        task.status = .completed
        store.updateTask(task, in: projectID)
    }

    @Test func deleteTaskTriggersRescheduleWithoutCrash() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        let projectID = store.projects[0].id
        let taskID = store.projects[0].tasks[0].id
        store.deleteTask(taskID, from: projectID)
    }

    @Test func deleteProjectTriggersRescheduleWithoutCrash() {
        let store = ProjectStore()
        let manager = NotificationManager()
        store.notificationManager = manager

        store.deleteProject(at: IndexSet(integer: 0))
    }

    @Test func mutationsWorkWithoutNotificationManager() {
        let store = ProjectStore()
        // notificationManager is nil — all mutations should work fine
        let project = Project(name: "No Manager")
        store.addProject(project)
        store.deleteProject(at: IndexSet(integer: store.projects.count - 1))

        let projectID = store.projects[0].id
        let task = ProjectTask(title: "Test", dueDate: .now)
        store.addTask(task, to: projectID)
        var updatedTask = task
        updatedTask.title = "Updated"
        store.updateTask(updatedTask, in: projectID)
        store.deleteTask(task.id, from: projectID)
    }
}
