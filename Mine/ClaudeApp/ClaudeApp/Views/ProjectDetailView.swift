import SwiftUI

struct ProjectDetailView: View {
    @Environment(ProjectStore.self) private var store
    let project: Project
    @State private var showAddTask = false
    @State private var showEditProject = false
    @State private var taskToEdit: ProjectTask?
    @State private var taskToDelete: ProjectTask?

    private var currentProject: Project {
        store.projects.first(where: { $0.id == project.id }) ?? project
    }

    var body: some View {
        List {
            projectInfoSection
            progressSection
            tasksSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(currentProject.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showAddTask = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }

                    Button {
                        showEditProject = true
                    } label: {
                        Label("Edit Project", systemImage: "pencil")
                    }

                    Button {
                        store.archiveProject(project.id)
                    } label: {
                        Label("Archive Project", systemImage: "archivebox")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(projectID: project.id)
        }
        .sheet(isPresented: $showEditProject) {
            EditProjectView(project: currentProject)
        }
        .sheet(item: $taskToEdit) { task in
            EditTaskView(task: task, projectID: project.id)
        }
        .alert("Delete Task", isPresented: Binding(
            get: { taskToDelete != nil },
            set: { if !$0 { taskToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let task = taskToDelete {
                    store.deleteTask(task.id, from: project.id)
                }
                taskToDelete = nil
            }
        } message: {
            Text("Are you sure you want to permanently delete this task?")
        }
    }

    // MARK: - Project Info

    private var projectInfoSection: some View {
        Section("Details") {
            if !currentProject.descriptionText.isEmpty {
                Text(currentProject.descriptionText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Start Date") {
                Text(currentProject.startDate, style: .date)
            }

            LabeledContent("End Date") {
                Text(currentProject.endDate, style: .date)
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        Section("Progress") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(completedCount) of \(currentProject.activeTasks.count) tasks completed")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(currentProject.completionPercentage * 100))%")
                        .font(.subheadline.weight(.semibold))
                }

                ProgressView(value: currentProject.completionPercentage)
                    .tint(color(for: currentProject.colorName))

                HStack(spacing: 16) {
                    statusBadge(count: notStartedCount, label: "To Do", color: .gray)
                    statusBadge(count: inProgressCount, label: "In Progress", color: .blue)
                    statusBadge(count: completedCount, label: "Done", color: .green)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
    }

    private func statusBadge(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tasks

    private var tasksSection: some View {
        Section("Tasks") {
            if currentProject.activeTasks.isEmpty {
                ContentUnavailableView {
                    Label("No Tasks", systemImage: "checklist")
                } description: {
                    Text("Tap the menu to add tasks to this project.")
                }
            } else {
                ForEach(sortedTasks) { task in
                    TaskRow(task: task, projectID: project.id)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                taskToDelete = task
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                store.archiveTask(task.id, in: project.id)
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                taskToEdit = task
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var sortedTasks: [ProjectTask] {
        currentProject.activeTasks.sorted { a, b in
            if a.status == .completed && b.status != .completed { return false }
            if a.status != .completed && b.status == .completed { return true }
            if a.priority != b.priority { return a.priority < b.priority }
            return a.dueDate < b.dueDate
        }
    }

    private var completedCount: Int {
        currentProject.activeTasks.filter { $0.status == .completed }.count
    }

    private var inProgressCount: Int {
        currentProject.activeTasks.filter { $0.status == .inProgress }.count
    }

    private var notStartedCount: Int {
        currentProject.activeTasks.filter { $0.status == .notStarted }.count
    }

    private func color(for name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "green": return .green
        case "pink": return .pink
        default: return .blue
        }
    }
}

struct TaskRow: View {
    @Environment(ProjectStore.self) private var store
    let task: ProjectTask
    let projectID: UUID

    var body: some View {
        HStack(spacing: 12) {
            Button {
                cycleStatus()
            } label: {
                Image(systemName: task.status.icon)
                    .foregroundStyle(statusColor)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.status == .completed, color: .secondary)

                HStack(spacing: 8) {
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(isDueSoon ? .red : .secondary)

                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.15))
                        .foregroundStyle(priorityColor)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func cycleStatus() {
        let updated = task
        switch task.status {
        case .notStarted: updated.status = .inProgress
        case .inProgress: updated.status = .completed
        case .completed: updated.status = .notStarted
        }
        store.updateTask(updated, in: projectID)
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
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    private var isDueSoon: Bool {
        task.status != .completed && task.dueDate < Calendar.current.date(byAdding: .day, value: 2, to: .now)!
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project(name: "Sample", descriptionText: "A sample project", tasks: [
            ProjectTask(title: "Task 1", dueDate: .now, status: .completed, priority: .high),
            ProjectTask(title: "Task 2", dueDate: .now, status: .inProgress, priority: .medium),
            ProjectTask(title: "Task 3", dueDate: .now, priority: .low),
        ]))
    }
    .environment(ProjectStore.preview())
}
