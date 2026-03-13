import SwiftUI
import TipKit

struct SearchView: View {
    @Environment(ProjectStore.self) private var store
    @State private var searchText = ""
    @State private var priorityFilter: TaskPriority?
    private var searchFilterTip = SearchFilterTip()

    private var isFiltering: Bool {
        !searchText.isEmpty || priorityFilter != nil
    }

    private var matchingProjects: [Project] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return store.activeProjects.filter {
            $0.name.lowercased().contains(query) ||
            $0.descriptionText.lowercased().contains(query)
        }
    }

    private var matchingTasks: [(project: Project, task: ProjectTask)] {
        var results: [(project: Project, task: ProjectTask)] = []
        for project in store.activeProjects {
            for task in project.activeTasks {
                if let filter = priorityFilter, task.priority != filter {
                    continue
                }
                if !searchText.isEmpty {
                    let query = searchText.lowercased()
                    guard task.title.lowercased().contains(query) ||
                          task.details.lowercased().contains(query) else {
                        continue
                    }
                }
                results.append((project: project, task: task))
            }
        }
        return results
    }

    var body: some View {
        NavigationStack {
            Group {
                if !isFiltering {
                    ContentUnavailableView {
                        Label("Search", systemImage: "magnifyingglass")
                    } description: {
                        Text("Search for projects and tasks by name, or filter tasks by priority.")
                    }
                } else if matchingProjects.isEmpty && matchingTasks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        if !matchingProjects.isEmpty {
                            Section("Projects") {
                                ForEach(matchingProjects) { project in
                                    NavigationLink(value: project.id) {
                                        ProjectRow(project: project)
                                    }
                                }
                            }
                        }

                        if !matchingTasks.isEmpty {
                            Section("Tasks") {
                                ForEach(matchingTasks, id: \.task.id) { item in
                                    NavigationLink(value: item.project.id) {
                                        SearchTaskRow(task: item.task, projectName: item.project.name)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Search")
            .navigationDestination(for: UUID.self) { projectID in
                if let project = store.projects.first(where: { $0.id == projectID }) {
                    ProjectDetailView(project: project)
                }
            }
            .searchable(text: $searchText, prompt: "Projects or tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            priorityFilter = nil
                        } label: {
                            if priorityFilter == nil {
                                Label("All Priorities", systemImage: "checkmark")
                            } else {
                                Text("All Priorities")
                            }
                        }
                        Divider()
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Button {
                                priorityFilter = priority
                                searchFilterTip.invalidate(reason: .actionPerformed)
                            } label: {
                                if priorityFilter == priority {
                                    Label(priority.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(priority.rawValue)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: priorityFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .popoverTip(searchFilterTip)
                    .accessibilityLabel(priorityFilter != nil ? "Filter: \(priorityFilter!.rawValue)" : "Filter by priority")
                    .accessibilityHint("Double tap to change priority filter")
                }
            }
        }
    }
}

// MARK: - Search Task Row

struct SearchTaskRow: View {
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

                HStack(spacing: 8) {
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.15))
                        .foregroundStyle(priorityColor)
                        .clipShape(Capsule())

                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(projectName), \(task.status.rawValue), \(task.priority.rawValue) priority")
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
    SearchView()
        .environment(ProjectStore.preview())
}
