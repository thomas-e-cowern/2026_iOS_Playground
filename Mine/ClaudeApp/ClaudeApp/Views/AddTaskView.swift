import SwiftUI

struct AddTaskView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let projectID: UUID

    @State private var title = ""
    @State private var details = ""
    @State private var dueDate = Date.now
    @State private var priority: TaskPriority = .medium
    @State private var recurrenceRule: RecurrenceRule = .none
    @State private var steps: [TaskStep] = []
    @State private var newStepTitle = ""

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

                Section("Recurrence") {
                    Picker("Repeat", selection: $recurrenceRule) {
                        ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                }

                StepsSectionView(
                    steps: $steps,
                    newStepTitle: $newStepTitle
                )
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CancelToolbarItem()

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = ProjectTask(
                            title: title,
                            details: details,
                            dueDate: dueDate,
                            priority: priority,
                            recurrenceRule: recurrenceRule,
                            steps: steps
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

struct StepsSectionView: View {
    @Binding var steps: [TaskStep]
    @Binding var newStepTitle: String

    var body: some View {
        Section("Steps") {
            ForEach($steps) { $step in
                TextField("Step", text: $step.title)
            }
            .onDelete { offsets in
                steps.remove(atOffsets: offsets)
            }
            .onMove { from, to in
                steps.move(fromOffsets: from, toOffset: to)
            }

            HStack {
                TextField("Add a step", text: $newStepTitle)

                Button {
                    let trimmed = newStepTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }

                    steps.append(TaskStep(title: trimmed))
                    newStepTitle = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newStepTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
