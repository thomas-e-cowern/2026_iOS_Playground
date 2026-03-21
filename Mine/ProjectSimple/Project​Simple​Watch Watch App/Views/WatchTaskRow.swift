import SwiftUI

struct WatchTaskRow: View {
    @Environment(WatchProjectStore.self) private var store
    let task: ProjectTask
    let projectName: String

    var body: some View {
        NavigationLink(destination: WatchTaskDetailView(task: task, projectName: projectName)) {
            HStack(spacing: 8) {
                Button {
                    store.cycleTaskStatus(task)
                } label: {
                    Image(systemName: task.status.icon)
                        .foregroundStyle(statusColor)
                        .font(.body)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.caption)
                        .lineLimit(2)
                        .strikethrough(task.status == .completed)
                        .foregroundStyle(task.status == .completed ? .secondary : .primary)

                    HStack(spacing: 4) {
                        Text(task.priority.rawValue)
                            .font(.caption2)
                            .foregroundStyle(priorityColor)

                        if !task.steps.isEmpty {
                            Text("\(task.completedStepsCount)/\(task.steps.count)")
                                .font(.caption2)
                                .foregroundStyle(task.completedStepsCount == task.steps.count ? .green : .secondary)
                        }
                    }
                }
            }
        }
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
