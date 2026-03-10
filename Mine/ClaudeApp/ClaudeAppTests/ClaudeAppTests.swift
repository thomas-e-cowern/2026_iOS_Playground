import Testing
import Foundation
@testable import ClaudeApp

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
        let task = ProjectTask(title: "Test", dueDate: .now)
        #expect(task.title == "Test")
        #expect(task.details == "")
        #expect(task.status == .notStarted)
        #expect(task.priority == .medium)
    }

    @Test func customInitValues() {
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
        #expect(task.id == id)
        #expect(task.title == "Custom")
        #expect(task.details == "Some details")
        #expect(task.dueDate == date)
        #expect(task.status == .completed)
        #expect(task.priority == .high)
    }

    @Test func encodingAndDecoding() throws {
        let task = ProjectTask(
            title: "Encode Me",
            details: "Details",
            dueDate: Date(timeIntervalSince1970: 1000000),
            status: .inProgress,
            priority: .low
        )
        let data = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(ProjectTask.self, from: data)
        #expect(decoded.id == task.id)
        #expect(decoded.title == task.title)
        #expect(decoded.details == task.details)
        #expect(decoded.status == task.status)
        #expect(decoded.priority == task.priority)
    }
}

// MARK: - Project Tests

@MainActor
struct ProjectTests {

    @Test func defaultInitValues() {
        let project = Project(name: "Test Project")
        #expect(project.name == "Test Project")
        #expect(project.description == "")
        #expect(project.tasks.isEmpty)
        #expect(project.colorName == "blue")
    }

    @Test func completionPercentageWithNoTasks() {
        let project = Project(name: "Empty")
        #expect(project.completionPercentage == 0)
    }

    @Test func completionPercentageWithAllCompleted() {
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .completed),
            ProjectTask(title: "B", dueDate: .now, status: .completed),
        ]
        let project = Project(name: "Done", tasks: tasks)
        #expect(project.completionPercentage == 1.0)
    }

    @Test func completionPercentagePartial() {
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .completed),
            ProjectTask(title: "B", dueDate: .now, status: .inProgress),
            ProjectTask(title: "C", dueDate: .now, status: .notStarted),
            ProjectTask(title: "D", dueDate: .now, status: .completed),
        ]
        let project = Project(name: "Partial", tasks: tasks)
        #expect(project.completionPercentage == 0.5)
    }

    @Test func completionPercentageNoneCompleted() {
        let tasks = [
            ProjectTask(title: "A", dueDate: .now, status: .notStarted),
            ProjectTask(title: "B", dueDate: .now, status: .inProgress),
        ]
        let project = Project(name: "None", tasks: tasks)
        #expect(project.completionPercentage == 0.0)
    }

    @Test func encodingAndDecoding() throws {
        let project = Project(
            name: "Encode Project",
            description: "Test encoding",
            tasks: [ProjectTask(title: "Task", dueDate: Date(timeIntervalSince1970: 1000000))],
            colorName: "purple"
        )
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
        #expect(decoded.id == project.id)
        #expect(decoded.name == project.name)
        #expect(decoded.description == project.description)
        #expect(decoded.tasks.count == 1)
        #expect(decoded.colorName == "purple")
    }
}
