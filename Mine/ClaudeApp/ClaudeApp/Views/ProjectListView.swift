import SwiftUI

struct ProjectListView: View {
    @Environment(ProjectStore.self) private var store
    @State private var showAddProject = false
    @State private var projectToEdit: Project?
    @State private var projectToDelete: Project?

    var body: some View {
        NavigationStack {
            Group {
                if store.activeProjects.isEmpty {
                    ContentUnavailableView {
                        Label("No Projects", systemImage: "folder")
                    } description: {
                        Text("Tap + to create your first project.")
                    }
                } else {
                    List {
                        ForEach(store.activeProjects) { project in
                            NavigationLink(value: project.id) {
                                ProjectRow(project: project)
                            }
                            .rowSwipeActions(onDelete: {
                                projectToDelete = project
                            }, onArchive: {
                                store.archiveProject(project.id)
                            }, onEdit: {
                                projectToEdit = project
                            })
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Projects")
            .navigationDestination(for: UUID.self) { projectID in
                if let project = store.projects.first(where: { $0.id == projectID }) {
                    ProjectDetailView(project: project)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add project")
                }
            }
            .sheet(isPresented: $showAddProject) {
                AddProjectView()
            }
            .sheet(item: $projectToEdit) { project in
                EditProjectView(project: project)
            }
            .alert("Delete Project", isPresented: Binding(
                get: { projectToDelete != nil },
                set: { if !$0 { projectToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    projectToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let project = projectToDelete {
                        store.deleteProject(project.id)
                    }
                    projectToDelete = nil
                }
            } message: {
                Text("Are you sure you want to permanently delete this project and all its tasks?")
            }
        }
    }
}

struct ProjectRow: View {
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

                Text(project.descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(project.category.rawValue, systemImage: project.category.icon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Label("\(project.tasks.count) tasks", systemImage: "checklist")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ProgressView(value: project.completionPercentage)
                        .frame(width: 60)
                        .accessibilityHidden(true)

                    Text("\(Int(project.completionPercentage * 100))%")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.name), \(project.category.rawValue), \(project.tasks.count) tasks, \(Int(project.completionPercentage * 100)) percent complete")
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

#Preview {
    ProjectListView()
        .environment(ProjectStore.preview())
}
