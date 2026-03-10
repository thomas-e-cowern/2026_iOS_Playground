import SwiftUI

struct EditTaskView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let task: ProjectTask
    let projectID: UUID

    @State private var title: String
    @State private var details: String
    @State private var dueDate: Date
    @State private var priority: TaskPriority
    @State private var status: TaskStatus

    init(task: ProjectTask, projectID: UUID) {
        self.task = task
        self.projectID = projectID
        _title = State(initialValue: task.title)
        _details = State(initialValue: task.details)
        _dueDate = State(initialValue: task.dueDate)
        _priority = State(initialValue: task.priority)
        _status = State(initialValue: task.status)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Info") {
                    TextField("Task Title", text: $title)
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Schedule") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = task
                        updated.title = title
                        updated.details = details
                        updated.dueDate = dueDate
                        updated.priority = priority
                        updated.status = status
                        store.updateTask(updated, in: projectID)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditTaskView(
        task: ProjectTask(title: "Sample Task", dueDate: .now, priority: .high),
        projectID: UUID()
    )
    .environment(ProjectStore())
}
