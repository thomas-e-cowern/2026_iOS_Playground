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

// MARK: - ProjectCategory Tests

struct ProjectCategoryTests {

    @Test func rawValues() {
        #expect(ProjectCategory.work.rawValue == "Work")
        #expect(ProjectCategory.personal.rawValue == "Personal")
        #expect(ProjectCategory.education.rawValue == "Education")
        #expect(ProjectCategory.health.rawValue == "Health")
        #expect(ProjectCategory.finance.rawValue == "Finance")
        #expect(ProjectCategory.other.rawValue == "Other")
    }

    @Test func icons() {
        #expect(ProjectCategory.work.icon == "briefcase.fill")
        #expect(ProjectCategory.personal.icon == "person.fill")
        #expect(ProjectCategory.education.icon == "book.fill")
        #expect(ProjectCategory.health.icon == "heart.fill")
        #expect(ProjectCategory.finance.icon == "dollarsign.circle.fill")
        #expect(ProjectCategory.other.icon == "folder.fill")
    }

    @Test func allCasesContainsAllCategories() {
        #expect(ProjectCategory.allCases.count == 6)
    }
}
