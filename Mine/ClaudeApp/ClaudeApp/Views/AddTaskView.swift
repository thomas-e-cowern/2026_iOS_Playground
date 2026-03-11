import SwiftUI

struct AddTaskView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let projectID: UUID

    @State private var title = ""
    @State private var details = ""
    @State private var dueDate = Date.now
    @State private var priority: TaskPriority = .medium

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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = ProjectTask(
                            title: title,
                            details: details,
                            dueDate: dueDate,
                            priority: priority
                        )
                        store.addTask(task, to: projectID)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTaskView(projectID: UUID())
        .environment(ProjectStore.preview())
}
