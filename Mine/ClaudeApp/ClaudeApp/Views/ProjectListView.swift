import SwiftUI

struct ProjectListView: View {
    @Environment(ProjectStore.self) private var store
    @State private var showAddProject = false

    var body: some View {
        NavigationStack {
            Group {
                if store.projects.isEmpty {
                    ContentUnavailableView {
                        Label("No Projects", systemImage: "folder")
                    } description: {
                        Text("Tap + to create your first project.")
                    }
                } else {
                    List {
                        ForEach(store.projects) { project in
                            NavigationLink(value: project.id) {
                                ProjectRow(project: project)
                            }
                        }
                        .onDelete { offsets in
                            store.deleteProject(at: offsets)
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
                }
            }
            .sheet(isPresented: $showAddProject) {
                AddProjectView()
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

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)

                Text(project.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label("\(project.tasks.count) tasks", systemImage: "checklist")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ProgressView(value: project.completionPercentage)
                        .frame(width: 60)

                    Text("\(Int(project.completionPercentage * 100))%")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
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
        .environment(ProjectStore())
}
