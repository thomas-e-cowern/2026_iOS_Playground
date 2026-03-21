import SwiftUI

struct WatchTaskDetailView: View {
    @Environment(WatchProjectStore.self) private var store
    let task: ProjectTask
    let projectName: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Status button
                Button {
                    store.cycleTaskStatus(task)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: task.status.icon)
                            .foregroundStyle(statusColor)
                        Text(task.status.rawValue)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)

                // Priority
                HStack(spacing: 6) {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Due date
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(task.dueDate, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                }

                // Project
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Recurrence
                if task.recurrenceRule != .none {
                    HStack(spacing: 6) {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(task.recurrenceRule.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Details
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Steps
                if !task.steps.isEmpty {
                    Divider()
                    Text("Steps (\(task.completedStepsCount)/\(task.steps.count))")
                        .font(.caption.bold())

                    ForEach(task.steps) { step in
                        Button {
                            store.toggleStep(stepID: step.id, in: task)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(step.isCompleted ? .green : .gray)
                                    .font(.caption)
                                Text(step.title)
                                    .font(.caption2)
                                    .strikethrough(step.isCompleted)
                                    .foregroundStyle(step.isCompleted ? .secondary : .primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(task.title)
    }

    private var isOverdue: Bool {
        task.status != .completed && task.dueDate < Calendar.current.startOfDay(for: .now)
    }

    private var statusColor: Color {
        switch task.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
