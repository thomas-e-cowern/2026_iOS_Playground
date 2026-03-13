import SwiftUI

struct ArchiveView: View {
    @Environment(ProjectStore.self) private var store
    @State private var selectedSection: ArchiveSection = .archived

    enum ArchiveSection: String, CaseIterable {
        case archived = "Archived"
        case completed = "Completed"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedSection) {
                    ForEach(ArchiveSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .accessibilityLabel("Archive section")
                .accessibilityHint("Switch between archived and completed items")

                Group {
                    switch selectedSection {
                    case .archived:
                        archivedContent
                    case .completed:
                        completedContent
                    }
                }
            }
            .navigationTitle("Archive")
        }
    }

    // MARK: - Archived Content

    @ViewBuilder
    private var archivedContent: some View {
        let archivedProjects = store.archivedProjects
        let projectsWithArchivedTasks = store.activeProjects.filter { project in
            project.tasks.contains { $0.isArchived }
        }

        if archivedProjects.isEmpty && projectsWithArchivedTasks.isEmpty {
            ContentUnavailableView {
                Label("No Archived Items", systemImage: "archivebox")
            } description: {
                Text("Swipe left on projects or tasks to archive them.")
            }
        } else {
            List {
                if !archivedProjects.isEmpty {
                    Section("Archived Projects") {
                        ForEach(archivedProjects) { project in
                            ArchivedProjectRow(project: project)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        store.deleteProject(project.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        store.unarchiveProject(project.id)
                                    } label: {
                                        Label("Unarchive", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }

                ForEach(projectsWithArchivedTasks) { project in
                    Section("Archived Tasks — \(project.name)") {
                        ForEach(project.tasks.filter(\.isArchived)) { task in
                            ArchivedTaskRow(task: task, projectName: project.name)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        store.deleteTask(task.id, from: project.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        store.unarchiveTask(task.id, in: project.id)
                                    } label: {
                                        Label("Unarchive", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Completed Content

    @ViewBuilder
    private var completedContent: some View {
        let fullyCompletedProjects = store.completedProjects
        let projectsWithCompletedTasks = store.activeProjects.filter { project in
            project.activeTasks.contains { $0.status == .completed }
        }

        if fullyCompletedProjects.isEmpty && projectsWithCompletedTasks.isEmpty {
            ContentUnavailableView {
                Label("No Completed Items", systemImage: "checkmark.circle")
            } description: {
                Text("Completed projects and tasks will appear here.")
            }
        } else {
            List {
                if !fullyCompletedProjects.isEmpty {
                    Section("Completed Projects") {
                        ForEach(fullyCompletedProjects) { project in
                            ArchivedProjectRow(project: project)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        store.archiveProject(project.id)
                                    } label: {
                                        Label("Archive", systemImage: "archivebox")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                }

                ForEach(projectsWithCompletedTasks) { project in
                    Section("Completed Tasks — \(project.name)") {
                        ForEach(project.activeTasks.filter { $0.status == .completed }) { task in
                            ArchivedTaskRow(task: task, projectName: project.name)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        store.archiveTask(task.id, in: project.id)
                                    } label: {
                                        Label("Archive", systemImage: "archivebox")
                                    }
                                    .tint(.orange)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        let updated = task
                                        updated.status = .inProgress
                                        store.updateTask(updated, in: project.id)
                                    } label: {
                                        Label("Reopen", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Row Views

struct ArchivedProjectRow: View {
    let project: Project

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color(for: project.colorName))
                .frame(width: 6, height: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)

                if !project.descriptionText.isEmpty {
                    Text(project.descriptionText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    Label("\(project.tasks.count) tasks", systemImage: "checklist")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if project.isArchived {
                        Text("Archived")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }

                    if project.completionPercentage == 1.0 {
                        Text("Complete")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.name), \(project.tasks.count) tasks\(project.isArchived ? ", archived" : "")\(project.completionPercentage == 1.0 ? ", complete" : "")")
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

struct ArchivedTaskRow: View {
    let task: ProjectTask
    let projectName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.status.icon)
                .foregroundStyle(statusColor)
                .font(.title3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.status == .completed, color: .secondary)

                HStack(spacing: 8) {
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.15))
                        .foregroundStyle(priorityColor)
                        .clipShape(Capsule())

                    if task.isArchived {
                        Text("Archived")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.status.rawValue), \(task.priority.rawValue) priority\(task.isArchived ? ", archived" : "")")
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
}

#Preview {
    ArchiveView()
        .environment(ProjectStore.preview())
}
