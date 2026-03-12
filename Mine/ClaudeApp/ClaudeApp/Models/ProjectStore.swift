import Foundation
import SwiftUI
import SwiftData

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
        save()
        scheduleNotifications()
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
                if calendar.isDate(task.dueDate, inSameDayAs: date) {
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

        let designTasks = [
            ProjectTask(title: "Create wireframes", details: "Design low-fidelity wireframes for all screens", dueDate: calendar.date(byAdding: .day, value: 1, to: today)!, status: .completed, priority: .high),
            ProjectTask(title: "Design system setup", details: "Define colors, typography, and spacing tokens", dueDate: calendar.date(byAdding: .day, value: 3, to: today)!, status: .inProgress, priority: .high),
            ProjectTask(title: "High-fidelity mockups", details: "Create detailed mockups for key screens", dueDate: calendar.date(byAdding: .day, value: 7, to: today)!, status: .notStarted, priority: .medium),
            ProjectTask(title: "Prototype interactions", details: "Build interactive prototype for user testing", dueDate: calendar.date(byAdding: .day, value: 12, to: today)!, status: .notStarted, priority: .low),
        ]

        let backendTasks = [
            ProjectTask(title: "Set up database schema", details: "Design and implement the database models", dueDate: calendar.date(byAdding: .day, value: 2, to: today)!, status: .inProgress, priority: .high),
            ProjectTask(title: "Authentication API", details: "Implement JWT-based auth endpoints", dueDate: calendar.date(byAdding: .day, value: 5, to: today)!, status: .notStarted, priority: .high),
            ProjectTask(title: "REST endpoints", details: "Build CRUD endpoints for all resources", dueDate: calendar.date(byAdding: .day, value: 10, to: today)!, status: .notStarted, priority: .medium),
            ProjectTask(title: "Write unit tests", details: "Achieve 80% code coverage", dueDate: calendar.date(byAdding: .day, value: 14, to: today)!, status: .notStarted, priority: .medium),
            ProjectTask(title: "Deploy to staging", details: "Set up CI/CD and deploy to staging environment", dueDate: calendar.date(byAdding: .day, value: 18, to: today)!, status: .notStarted, priority: .low),
        ]

        let marketingTasks = [
            ProjectTask(title: "Market research", details: "Analyze competitor landscape and target audience", dueDate: calendar.date(byAdding: .day, value: -1, to: today)!, status: .completed, priority: .high),
            ProjectTask(title: "Brand guidelines", details: "Finalize brand voice, tone, and visual identity", dueDate: calendar.date(byAdding: .day, value: 4, to: today)!, status: .inProgress, priority: .medium),
            ProjectTask(title: "Content calendar", details: "Plan social media and blog content for launch", dueDate: calendar.date(byAdding: .day, value: 8, to: today)!, status: .notStarted, priority: .medium),
            ProjectTask(title: "Press release", details: "Draft and finalize launch press release", dueDate: calendar.date(byAdding: .day, value: 15, to: today)!, status: .notStarted, priority: .low),
        ]

        let project1 = Project(name: "App Redesign", descriptionText: "Complete UI/UX overhaul of the mobile app", startDate: today, endDate: calendar.date(byAdding: .month, value: 1, to: today)!, tasks: designTasks, colorName: "blue")
        let project2 = Project(name: "Backend Overhaul", descriptionText: "Migrate to new backend architecture", startDate: today, endDate: calendar.date(byAdding: .month, value: 2, to: today)!, tasks: backendTasks, colorName: "purple")
        let project3 = Project(name: "Marketing Launch", descriptionText: "Coordinate marketing efforts for product launch", startDate: calendar.date(byAdding: .day, value: -5, to: today)!, endDate: calendar.date(byAdding: .month, value: 1, to: today)!, tasks: marketingTasks, colorName: "orange")

        modelContext.insert(project1)
        modelContext.insert(project2)
        modelContext.insert(project3)
        save()
    }
}
