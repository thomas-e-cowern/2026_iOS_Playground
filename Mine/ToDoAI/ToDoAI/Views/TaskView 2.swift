import SwiftUI

struct TaskView: View {
    var task: ToDoProjectTask

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("", isOn: Binding(
                get: { task.completed },
                set: { newValue in task.completed = newValue }
            ))
                .labelsHidden()
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.completed, pattern: .solid, color: .secondary)
                    priorityLabel
                }
                if !task.detail.isEmpty {
                    Text(task.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var priorityLabel: some View {
        let text: String
        let color: Color
        switch task.priority {
        case .low:
            text = "Low"
            color = .blue
        case .normal:
            text = "Normal"
            color = .gray
        case .high:
            text = "High"
            color = .red
        }
        return Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    List {
        TaskView(task: ToDoProjectTask(title: "Buy milk", detail: "2% organic", priority: .normal, completed: false))
        TaskView(task: ToDoProjectTask(title: "Ship build", detail: "v1.0.3 to TestFlight", priority: .high, completed: true))
        TaskView(task: ToDoProjectTask(title: "Plan sprint", detail: "Backlog grooming", priority: .low, completed: false))
    }
}
