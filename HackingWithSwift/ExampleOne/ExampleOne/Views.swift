import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingNewProject = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.projects) { project in
                    NavigationLink(value: project) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name).font(.headline)
                            if !project.notes.isEmpty { Text(project.notes).font(.subheadline).foregroundStyle(.secondary) }
                            HStack {
                                Text("\(project.tasks.filter{ !$0.isCompleted }.count) open")
                                Text("·")
                                Text("\(project.tasks.filter{ $0.isCompleted }.count) done")
                            }.font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewProject = true
                    } label: { Label("New Project", systemImage: "plus") }
                }
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .sheet(isPresented: $showingNewProject) {
                NewProjectSheet()
                    .environmentObject(store)
            }
        }
    }
}

struct ProjectDetailView: View {
    @EnvironmentObject var store: AppStore
    let project: Project
    @State private var newTaskTitle: String = ""
    @State private var dueDate: Date? = nil
    @State private var showingAIBreakdown = false

    var body: some View {
        List {
            Section("Add Task") {
                TextField("Task title", text: $newTaskTitle)
                DatePicker("Due", selection: Binding(get: { dueDate ?? Date() }, set: { dueDate = $0 }), displayedComponents: .date)
                    .datePickerStyle(.compact)
                Button("Add") {
                    guard !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    store.addTask(to: project.id, title: newTaskTitle, dueDate: dueDate)
                    newTaskTitle = ""
                    dueDate = nil
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("Tasks") {
                ForEach(store.projects.first(where: { $0.id == project.id })?.tasks ?? []) { task in
                    HStack {
                        Button {
                            store.toggleTask(task.id, in: project.id)
                        } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompleted ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        VStack(alignment: .leading) {
                            Text(task.title)
                            if let d = task.dueDate { Text(d.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary) }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAIBreakdown = true
                } label: { Label("Swiss Cheese", systemImage: "square.stack.3d.up") }
            }
        }
        .sheet(isPresented: $showingAIBreakdown) {
            AIBreakdownSheet(project: project)
                .environmentObject(store)
        }
    }
}

struct NewProjectSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var hasDueDate: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Project name", text: $name)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    Toggle("Has due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addProject(name: name, notes: notes, dueDate: hasDueDate ? dueDate : nil)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct AIBreakdownSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let project: Project
    @State private var suggestions: [String] = []
    private let ai = AIBreakdownService()

    var body: some View {
        NavigationStack {
            List {
                if suggestions.isEmpty {
                    ProgressView("Generating suggestions...")
                        .task { load() }
                } else {
                    Section("Suggested next slices") {
                        ForEach(suggestions, id: \.self) { s in
                            HStack {
                                Text(s)
                                Spacer()
                                Button { store.addTask(to: project.id, title: s) } label: {
                                    Image(systemName: "plus.circle.fill").foregroundStyle(.tint)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Swiss Cheese")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button("Done") { dismiss() } } }
        }
    }

    private func load() {
        let p = store.projects.first(where: { $0.id == project.id }) ?? project
        suggestions = ai.breakdown(projectName: p.name, notes: p.notes)
    }
}

struct CalendarView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                List {
                    Section(header: Text(selectedDate.formatted(date: .complete, time: .omitted))) {
                        ForEach(store.tasks(on: selectedDate)) { task in
                            VStack(alignment: .leading) {
                                Text(task.title)
                                if let p = store.projects.first(where: { $0.id == task.projectID }) {
                                    Text(p.name).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
            .padding(.top)
        }
    }
}

struct TodayView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                Section("Due Today") {
                    ForEach(store.tasks(on: Date())) { task in
                        HStack {
                            Text(task.title)
                            Spacer()
                            if let p = store.projects.first(where: { $0.id == task.projectID }) {
                                Text(p.name).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("All Open Tasks") {
                    ForEach(store.projects.flatMap { $0.tasks }.filter { !$0.isCompleted }) { task in
                        VStack(alignment: .leading) {
                            Text(task.title)
                            if let d = task.dueDate { Text(d.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }
            }
            .navigationTitle("Today")
        }
    }
}
