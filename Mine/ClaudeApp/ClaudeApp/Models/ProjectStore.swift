import Foundation
import SwiftUI
import SwiftData
import WidgetKit

@MainActor
@Observable
class ProjectStore {
    let modelContext: ModelContext
    var notificationManager: NotificationManager?
    private(set) var projects: [Project] = []
    var errorMessage: String?

    var activeProjects: [Project] {
        projects.filter { !$0.isArchived }
    }

    var archivedProjects: [Project] {
        projects.filter { $0.isArchived }
    }

    var completedProjects: [Project] {
        projects.filter { !$0.isArchived && $0.completionPercentage == 1.0 }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSampleDataIfNeeded()
        refreshProjects()
    }

    private func refreshProjects() {
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.name)])
        projects = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
        refreshProjects()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func scheduleNotifications() {
        guard let manager = notificationManager else { return }
        let currentProjects = activeProjects
        Task {
            await manager.rescheduleAll(for: currentProjects)
        }
    }

    // MARK: - Project Operations

    func addProject(_ project: Project) {
        modelContext.insert(project)
        save()
        scheduleNotifications()
    }

    func updateProject(_ project: Project) {
        save()
        scheduleNotifications()
    }

    func deleteProject(at offsets: IndexSet) {
        let active = activeProjects
        for index in offsets {
            modelContext.delete(active[index])
        }
        save()
        scheduleNotifications()
    }

    func deleteProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }) {
            modelContext.delete(project)
            save()
        }
        scheduleNotifications()
    }

    func archiveProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }) {
            project.isArchived = true
            save()
        }
        scheduleNotifications()
    }

    func unarchiveProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }) {
            project.isArchived = false
            save()
        }
        scheduleNotifications()
    }

    // MARK: - Task Operations

    func addTask(_ task: ProjectTask, to projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }) {
            project.tasks.append(task)
            save()
        }
        scheduleNotifications()
    }

    func updateTask(_ task: ProjectTask, in projectID: UUID) {
        generateNextOccurrenceIfNeeded(for: task, in: projectID)
        save()
        scheduleNotifications()
    }

    // MARK: - Recurrence

    private func generateNextOccurrenceIfNeeded(for task: ProjectTask, in projectID: UUID) {
        guard task.status == .completed,
              task.recurrenceRule != .none,
              !task.hasGeneratedNextOccurrence,
              let nextDate = task.recurrenceRule.nextDueDate(from: task.dueDate),
              let project = projects.first(where: { $0.id == projectID })
        else { return }

        let nextTask = ProjectTask(
            title: task.title,
            details: task.details,
            dueDate: nextDate,
            priority: task.priority,
            recurrenceRule: task.recurrenceRule
        )

        task.hasGeneratedNextOccurrence = true
        project.tasks.append(nextTask)
    }

    func deleteTask(_ taskID: UUID, from projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }),
           let task = project.tasks.first(where: { $0.id == taskID }) {
            modelContext.delete(task)
            save()
        }
        scheduleNotifications()
    }

    func archiveTask(_ taskID: UUID, in projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }),
           let task = project.tasks.first(where: { $0.id == taskID }) {
            task.isArchived = true
            save()
        }
        scheduleNotifications()
    }

    func unarchiveTask(_ taskID: UUID, in projectID: UUID) {
        if let project = projects.first(where: { $0.id == projectID }),
           let task = project.tasks.first(where: { $0.id == taskID }) {
            task.isArchived = false
            save()
        }
        scheduleNotifications()
    }

    // MARK: - Calendar Helpers

    func tasks(for date: Date) -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                if calendar.isDate(task.dueDate, inSameDayAs: date) && task.status != .completed {
                    results.append((project: project, task: task))
                }
            }
        }
        return results
    }

    func overdueTasks() -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                if task.status != .completed && task.dueDate < startOfToday {
                    results.append((project: project, task: task))
                }
            }
        }
        return results.sorted { $0.task.dueDate < $1.task.dueDate }
    }

    func allTasks() -> [(project: Project, task: ProjectTask)] {
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                results.append((project: project, task: task))
            }
        }
        return results
    }

    // MARK: - Preview Helper

    static func preview() -> ProjectStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
        return ProjectStore(modelContext: container.mainContext)
    }

    // MARK: - Sample Data

    private func loadSampleDataIfNeeded() {
        let descriptor = FetchDescriptor<Project>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        loadSampleData()
    }

    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date.now

        let gettingStartedTasks = [
            ProjectTask(
                title: "Explore this project",
                details: "Tap this project to see its tasks. You're looking at one now! Each task has a status, priority, and due date.",
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                status: .inProgress,
                priority: .high
            ),
            ProjectTask(
                title: "Mark a task complete",
                details: "Open any task and change its status to Completed. Try it with the 'Explore this project' task once you're done reading it.",
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                status: .notStarted,
                priority: .high
            ),
            ProjectTask(
                title: "Add your own task",
                details: "Tap the + button at the top of the project to add a new task. Give it a title, due date, and priority.",
                dueDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                status: .notStarted,
                priority: .medium
            ),
            ProjectTask(
                title: "Try the Search tab",
                details: "Switch to the Search tab to find tasks across all projects. You can filter by priority and category using the filter button.",
                dueDate: calendar.date(byAdding: .day, value: 4, to: today)!,
                status: .notStarted,
                priority: .medium
            ),
            ProjectTask(
                title: "Check the Calendar tab",
                details: "The Calendar tab shows tasks by due date. Tap any date to see what's due. Overdue tasks appear at the top.",
                dueDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                status: .notStarted,
                priority: .low
            ),
            ProjectTask(
                title: "Create your first project",
                details: "Go back to the Projects tab and tap + to create a new project. Choose a name, color, category, and date range. Once you're comfortable, feel free to delete this Getting Started project.",
                dueDate: calendar.date(byAdding: .day, value: 7, to: today)!,
                status: .notStarted,
                priority: .low
            ),
        ]

        let gettingStarted = Project(
            name: "Getting Started",
            descriptionText: "Welcome! This project walks you through the basics of the app. Complete each task to learn how things work.",
            startDate: today,
            endDate: calendar.date(byAdding: .month, value: 1, to: today)!,
            tasks: gettingStartedTasks,
            colorName: "blue",
            category: .personal
        )

        modelContext.insert(gettingStarted)
        save()
    }
}
