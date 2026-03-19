import SwiftUI
import TipKit

struct SearchView: View {
    @Environment(ProjectStore.self) private var store
    @State private var searchText = ""
    @State private var priorityFilter: TaskPriority?
    @State private var categoryFilter: ProjectCategory?
    private var searchFilterTip = SearchFilterTip()
    
    private var isFiltering: Bool {
        !searchText.isEmpty || priorityFilter != nil || categoryFilter != nil
    }
    
    private var hasActiveFilter: Bool {
        priorityFilter != nil || categoryFilter != nil
    }
    
    private var filterAccessibilityLabel: String {
        var parts: [String] = []
        if let priorityFilter {
            parts.append(priorityFilter.rawValue)
        }
        if let categoryFilter {
            parts.append(categoryFilter.rawValue)
        }
        return parts.isEmpty ? "Filter by priority or category" : "Filter: \(parts.joined(separator: ", "))"
    }
    
    private var matchingProjects: [Project] {
        var results = store.activeProjects
        
        if let categoryFilter {
            results = results.filter { $0.category == categoryFilter }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.descriptionText.lowercased().contains(query)
            }
        } else if categoryFilter == nil {
            return []
        }
        
        return results
    }
    
    private var matchingTasks: [(project: Project, task: ProjectTask)] {
        var results: [(project: Project, task: ProjectTask)] = []
        for project in store.activeProjects {
            if let categoryFilter, project.category != categoryFilter {
                continue
            }
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
                        Text("Search for projects and tasks by name, or filter by priority and category.")
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
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        store.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(!store.undoManager.canUndo)
                    .accessibilityLabel("Undo")

                    Button {
                        store.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    .disabled(!store.undoManager.canRedo)
                    .accessibilityLabel("Redo")
                }

                TaskFilterToolbar(
                    priorityFilter: $priorityFilter,
                    categoryFilter: $categoryFilter,
                    searchFilterTip: searchFilterTip
                )
            }
        }
    }
}

#Preview {
    SearchView()
        .environment(ProjectStore.preview())
}
