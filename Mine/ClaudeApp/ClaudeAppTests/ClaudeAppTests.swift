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

// MARK: - TaskStatus Tests

struct TaskStatusTests {

    @Test func rawValues() {
        #expect(TaskStatus.notStarted.rawValue == "Not Started")
        #expect(TaskStatus.inProgress.rawValue == "In Progress")
        #expect(TaskStatus.completed.rawValue == "Completed")
    }

    @Test func icons() {
        #expect(TaskStatus.notStarted.icon == "circle")
        #expect(TaskStatus.inProgress.icon == "circle.lefthalf.filled")
        #expect(TaskStatus.completed.icon == "checkmark.circle.fill")
    }

    @Test func allCasesContainsAllStatuses() {
        #expect(TaskStatus.allCases.count == 3)
        #expect(TaskStatus.allCases.contains(.notStarted))
        #expect(TaskStatus.allCases.contains(.inProgress))
        #expect(TaskStatus.allCases.contains(.completed))
    }
}

// MARK: - TaskPriority Tests

struct TaskPriorityTests {

    @Test func rawValues() {
        #expect(TaskPriority.low.rawValue == "Low")
        #expect(TaskPriority.medium.rawValue == "Medium")
        #expect(TaskPriority.high.rawValue == "High")
    }

    @Test func colors() {
        #expect(TaskPriority.low.color == "green")
        #expect(TaskPriority.medium.color == "orange")
        #expect(TaskPriority.high.color == "red")
    }

    @Test func comparableOrdersHighBeforeLow() {
        #expect(TaskPriority.high < TaskPriority.medium)
        #expect(TaskPriority.medium < TaskPriority.low)
        #expect(TaskPriority.high < TaskPriority.low)
    }

    @Test func sortingProducesHighMediumLowOrder() {
        let priorities: [TaskPriority] = [.low, .high, .medium]
        let sorted = priorities.sorted()
        #expect(sorted == [.high, .medium, .low])
    }

    @Test func allCasesContainsAllPriorities() {
        #expect(TaskPriority.allCases.count == 3)
    }
}

// MARK: - ProjectTask Tests

@MainActor
struct ProjectTaskTests {

    @Test func defaultInitValues() {
        let context = makeContext()
        let task = ProjectTask(title: "Test", dueDate: .now)
        context.insert(task)
        #expect(task.title == "Test")
        #expect(task.details == "")
        #expect(task.status == .notStarted)
        #expect(task.priority == .medium)
        #expect(task.isArchived == false)
    }

    @Test func customInitValues() {
        let context = makeContext()
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
        context.insert(task)
        #expect(task.id == id)
        #expect(task.title == "Custom")
        #expect(task.details == "Some details")
        #expect(task.dueDate == date)
        #expect(task.status == .completed)
        #expect(task.priority == .high)
    }
}

// MARK: - Project Tests

@MainActor
struct ProjectTests {

    @Test func defaultInitValues() {
        let context = makeContext()
        let project = Project(name: "Test Project")
        context.insert(project)
        #expect(project.name == "Test Project")
        #expect(project.descriptionText == "")
        #expect(project.tasks.isEmpty)
        #expect(project.colorName == "blue")
        #expect(project.isArchived == false)
    }

    @Test func activeTasksExcludesArchived() {
        let context = makeContext()
        let tasks = [
            ProjectTask(title: "A", dueDate: .now),
            ProjectTask(title: "B", dueDate: .now, isArchived: true),
            ProjectTask(title: "C", dueDate: .now),
        ]
        let project = Project(name: "Filter Test", tasks: tasks)
        context.insert(project)
        #expect(project.activeTasks.count == 2)
        #expect(project.activeTasks.allSatisfy { !$0.isArchived })
    }

    @Test func completionPercentageIgnoresArchivedTasks() {
        let context = makeContext()
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .completed),
            ProjectTask(title: "B", dueDate: .now, status: .notStarted),
            ProjectTask(title: "C", dueDate: .now, status: .completed, isArchived: true),
        ]
        let project = Project(name: "Mixed", tasks: tasks)
        context.insert(project)
        #expect(project.completionPercentage == 0.5)
    }

    @Test func completionPercentageWithNoTasks() {
        let context = makeContext()
        let project = Project(name: "Empty")
        context.insert(project)
        #expect(project.completionPercentage == 0)
    }

    @Test func completionPercentageWithAllCompleted() {
        let context = makeContext()
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .completed),
            ProjectTask(title: "B", dueDate: .now, status: .completed),
        ]
        let project = Project(name: "Done", tasks: tasks)
        context.insert(project)
        #expect(project.completionPercentage == 1.0)
    }

    @Test func completionPercentagePartial() {
        let context = makeContext()
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .completed),
            ProjectTask(title: "B", dueDate: .now, status: .inProgress),
            ProjectTask(title: "C", dueDate: .now, status: .notStarted),
            ProjectTask(title: "D", dueDate: .now, status: .completed),
        ]
        let project = Project(name: "Partial", tasks: tasks)
        context.insert(project)
        #expect(project.completionPercentage == 0.5)
    }

    @Test func completionPercentageNoneCompleted() {
        let context = makeContext()
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .notStarted),
            ProjectTask(title: "B", dueDate: .now, status: .inProgress),
        ]
        let project = Project(name: "None", tasks: tasks)
        context.insert(project)
        #expect(project.completionPercentage == 0.0)
    }
}
