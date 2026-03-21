import Foundation
import SwiftData
import WidgetKit
import WatchKit

@MainActor
@Observable
class WatchProjectStore {
    let modelContext: ModelContext
    private(set) var projects: [Project] = []

    var activeProjects: [Project] {
        projects.filter { !$0.isArchived }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSampleDataIfNeeded()
        refreshProjects()
    }

    func refreshProjects() {
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.name)])
        projects = (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Query Helpers

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

    func todayTasks() -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return []
        }
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                if task.status != .completed
                    && task.dueDate >= startOfToday
                    && task.dueDate < endOfToday {
                    results.append((project: project, task: task))
                }
            }
        }
        return results.sorted { $0.task.priority < $1.task.priority }
    }

    // MARK: - Mutations

    func cycleTaskStatus(_ task: ProjectTask) {
        let previousStatus = task.status
        switch task.status {
        case .notStarted: task.status = .inProgress
        case .inProgress: task.status = .completed
        case .completed: task.status = .notStarted
        }

        if task.status == .completed && previousStatus != .completed {
            task.completedDate = Date.now
        } else if task.status != .completed {
            task.completedDate = nil
        }

        save()
        WKInterfaceDevice.current().play(.click)
    }

    func toggleStep(stepID: UUID, in task: ProjectTask) {
        if let index = task.steps.firstIndex(where: { $0.id == stepID }) {
            task.steps[index].isCompleted.toggle()
            save()
            WKInterfaceDevice.current().play(.click)
        }
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Watch save error: \(error)")
        }
        refreshProjects()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Sample Data (for simulator testing)

    private func loadSampleDataIfNeeded() {
        let descriptor = FetchDescriptor<Project>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let calendar = Calendar.current
        let today = Date.now

        let tasks = [
            ProjectTask(
                title: "Review project plan",
                details: "Go through the project milestones",
                dueDate: today,
                status: .inProgress,
                priority: .high,
                steps: [
                    TaskStep(title: "Read overview"),
                    TaskStep(title: "Check timeline"),
                    TaskStep(title: "Note questions")
                ]
            ),
            ProjectTask(
                title: "Update documentation",
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                status: .notStarted,
                priority: .medium
            ),
            ProjectTask(
                title: "Send status report",
                dueDate: calendar.date(byAdding: .day, value: -1, to: today)!,
                status: .notStarted,
                priority: .high
            ),
            ProjectTask(
                title: "Team sync",
                dueDate: today,
                status: .notStarted,
                priority: .low
            ),
            ProjectTask(
                title: "Prepare demo",
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                status: .completed
            )
        ]

        let project = Project(
            name: "Sample Project",
            descriptionText: "A sample project for testing the watch app.",
            startDate: today,
            endDate: calendar.date(byAdding: .month, value: 1, to: today)!,
            tasks: tasks,
            colorName: "blue",
            category: .work
        )

        modelContext.insert(project)
        try? modelContext.save()
    }
}
