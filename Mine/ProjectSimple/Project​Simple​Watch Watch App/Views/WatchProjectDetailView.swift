import SwiftUI

struct WatchProjectDetailView: View {
    @Environment(WatchProjectStore.self) private var store
    let project: Project

    private var sortedTasks: [ProjectTask] {
        project.activeTasks.sorted { lhs, rhs in
            // Incomplete before complete
            if (lhs.status == .completed) != (rhs.status == .completed) {
                return lhs.status != .completed
            }
            // Then by priority (high first)
            if lhs.priority != rhs.priority {
                return lhs.priority < rhs.priority
            }
            // Then by due date
            return lhs.dueDate < rhs.dueDate
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    ProgressView(value: project.completionPercentage)
                        .tint(project.completionPercentage == 1.0 ? .green : .blue)
                    Text("\(Int(project.completionPercentage * 100))%")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }

            if sortedTasks.isEmpty {
                Text("No tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedTasks) { task in
                    WatchTaskRow(task: task, projectName: project.name)
                }
            }
        }
        .navigationTitle(project.name)
    }
}
