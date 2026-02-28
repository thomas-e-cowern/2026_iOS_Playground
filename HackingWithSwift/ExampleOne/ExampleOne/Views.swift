import SwiftUI

struct ProjectsView: View {
    @Environment(ProjectStore.self) private var store
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byName
    @State private var showArchived: Bool = false
    @State private var editingProject: Project? = nil
    @State private var showingNewProject = false

    enum SortOption: String, CaseIterable, Identifiable {
        case byName = "Name"
        case byOpenTasks = "Open Tasks"
        case byDueDate = "Due Date"
        var id: String { rawValue }
    }

    private var filteredProjects: [Project] {
        let base = showArchived ? store.projects : store.projects.filter { !$0.isArchived }
        let searched = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? base : base.filter { project in
            project.name.localizedCaseInsensitiveContains(searchText) || project.notes.localizedCaseInsensitiveContains(searchText)
        }
        switch sortOption {
        case .byName:
            return searched.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byOpenTasks:
            return searched.sorted { lhs, rhs in
                let l = lhs.tasks.filter { !$0.isCompleted }.count
                let r = rhs.tasks.filter { !$0.isCompleted }.count
                if l == r { return lhs.name < rhs.name }
                return l > r
            }
        case .byDueDate:
            return searched.sorted { (lhs, rhs) in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (l?, r?): return l < r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.name < rhs.name
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredProjects) { project in
                    NavigationLink(value: project) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name).font(.headline)
                            if !project.notes.isEmpty { Text(project.notes).font(.subheadline).foregroundStyle(.secondary) }
                            HStack {
                                Text("\(project.tasks.filter{ !$0.isCompleted }.count) open")
                                Text("·")
                                Text("\(project.tasks.filter{ $0.isCompleted }.count) done")
                            }.font(.caption).foregroundStyle(.secondary)
                            if project.isArchived { Text("Archived").font(.caption2).padding(4).background(.quaternary).clipShape(RoundedRectangle(cornerRadius: 6)) }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            // Implement deletion in AppStore
                            store.deleteProject(project)
                        } label: { Label("Delete", systemImage: "trash") }

                        Button {
                            // Toggle archive state in AppStore
                            store.archiveProject(project, archived: !project.isArchived)
                        } label: { Label(project.isArchived ? "Unarchive" : "Archive", systemImage: project.isArchived ? "tray.and.arrow.up" : "archivebox") }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingProject = project
                        } label: { Label("Edit", systemImage: "pencil") }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Projects")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Toggle(isOn: $showArchived) {
                        Label("Show Archived", systemImage: "archivebox")
                    }
                    .toggleStyle(.switch)
                }
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
            }
            .sheet(item: $editingProject) { proj in
                EditProjectSheet(project: proj)
            }
        }
    }
}

struct ProjectDetailView: View {
    @Environment(ProjectStore.self) private var store
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
                    store.addTask(to: project, title: newTaskTitle, dueDate: dueDate)
                    newTaskTitle = ""
                    dueDate = nil
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("Tasks") {
                ForEach(project.tasks) { task in
                    HStack {
                        Button {
                            store.toggleTask(task)
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.deleteTask(task)
                        } label: { Label("Delete", systemImage: "trash") }
                        Button {
                            store.archiveTask(task, archived: !task.isArchived)
                        } label: { Label(task.isArchived ? "Unarchive" : "Archive", systemImage: task.isArchived ? "tray.and.arrow.up" : "archivebox") }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            store.toggleTask(task)
                        } label: { Label(task.isCompleted ? "Mark Open" : "Complete", systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill") }
                        .tint(.green)
                        Button {
                            // Present a simple inline edit alert for task title
                            // Using a temporary approach: duplicate as new edited title via prompt
                            // This will be refined in a dedicated edit sheet if needed
                            // No-op placeholder if not supported
                        } label: { Label("Edit", systemImage: "pencil") }
                        .tint(.blue)
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
        }
    }
}

struct NewProjectSheet: View {
    @Environment(ProjectStore.self) private var store
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
    @Environment(ProjectStore.self) private var store
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
                                Button { store.addTask(to: project, title: s) } label: {
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
        suggestions = ai.breakdown(projectName: project.name, notes: project.notes)
    }
}

struct CalendarView: View {
    @Environment(ProjectStore.self) private var store
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
                                if let p = task.project {
                                    Text(p.name).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { store.deleteTask(task) } label: { Label("Delete", systemImage: "trash") }
                                Button { store.toggleTask(task) } label: { Label(task.isCompleted ? "Mark Open" : "Complete", systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill") }.tint(.green)
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
    @Environment(ProjectStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Section("Due Today") {
                    ForEach(store.tasks(on: Date())) { task in
                        HStack {
                            Text(task.title)
                            Spacer()
                            if let p = task.project {
                                Text(p.name).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { store.deleteTask(task) } label: { Label("Delete", systemImage: "trash") }
                            Button { store.toggleTask(task) } label: { Label(task.isCompleted ? "Mark Open" : "Complete", systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill") }.tint(.green)
                        }
                    }
                }
                Section("All Open Tasks") {
                    ForEach(store.projects.flatMap { $0.tasks }.filter { !$0.isCompleted }) { task in
                        VStack(alignment: .leading) {
                            Text(task.title)
                            if let d = task.dueDate { Text(d.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary) }
                            if let p = task.project {
                                Text(p.name).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { store.deleteTask(task) } label: { Label("Delete", systemImage: "trash") }
                            Button { store.toggleTask(task) } label: { Label(task.isCompleted ? "Mark Open" : "Complete", systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill") }.tint(.green)
                        }
                    }
                }
            }
            .navigationTitle("Today")
        }
    }
}
struct EditProjectSheet: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var notes: String
    let project: Project

    init(project: Project) {
        self.project = project
        _name = State(initialValue: project.name)
        _notes = State(initialValue: project.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Project name", text: $name)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateProject(project, name: name, notes: notes)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

