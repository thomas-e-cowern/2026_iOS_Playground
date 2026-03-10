import Foundation
import SwiftUI

@Observable
class ProjectStore {
    var projects: [Project] = []

    init() {
        loadSampleData()
    }

    // MARK: - Project Operations

    func addProject(_ project: Project) {
        projects.append(project)
    }

    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }

    func addTask(_ task: ProjectTask, to projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].tasks.append(task)
    }

    func updateTask(_ task: ProjectTask, in projectID: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectID }),
              let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == task.id })
        else { return }
        projects[projectIndex].tasks[taskIndex] = task
    }

    func deleteTask(_ taskID: UUID, from projectID: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[projectIndex].tasks.removeAll { $0.id == taskID }
    }

    // MARK: - Calendar Helpers

    func tasks(for date: Date) -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        var results: [(project: Project, task: ProjectTask)] = []
        for project in projects {
            for task in project.tasks {
                if calendar.isDate(task.dueDate, inSameDayAs: date) {
                    results.append((project: project, task: task))
                }
            }
        }
        return results
    }

    func allTasks() -> [(project: Project, task: ProjectTask)] {
        var results: [(project: Project, task: ProjectTask)] = []
        for project in projects {
            for task in project.tasks {
                results.append((project: project, task: task))
            }
        }
        return results
    }

    // MARK: - Sample Data

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

        projects = [
            Project(name: "App Redesign", description: "Complete UI/UX overhaul of the mobile app", startDate: today, endDate: calendar.date(byAdding: .month, value: 1, to: today)!, tasks: designTasks, colorName: "blue"),
            Project(name: "Backend Overhaul", description: "Migrate to new backend architecture", startDate: today, endDate: calendar.date(byAdding: .month, value: 2, to: today)!, tasks: backendTasks, colorName: "purple"),
            Project(name: "Marketing Launch", description: "Coordinate marketing efforts for product launch", startDate: calendar.date(byAdding: .day, value: -5, to: today)!, endDate: calendar.date(byAdding: .month, value: 1, to: today)!, tasks: marketingTasks, colorName: "orange"),
        ]
    }
}
