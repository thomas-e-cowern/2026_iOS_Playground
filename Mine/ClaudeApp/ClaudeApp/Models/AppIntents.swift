import AppIntents
import SwiftData

// MARK: - New Project Intent

struct NewProjectIntent: AppIntent {
    static var title: LocalizedStringResource = "New Project"
    static var description = IntentDescription("Creates a new project.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickActionState.shared.pendingAction = "com.claudeapp.newProject"
        return .result()
    }
}

// MARK: - Project Entity

struct ProjectEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "SimpleProject")
    static var defaultQuery = ProjectEntityQuery()

    var id: UUID
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ProjectEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [ProjectEntity] {
        let container = try ModelContainer(for: Project.self, ProjectTask.self)
        let context = container.mainContext
        let descriptor = FetchDescriptor<Project>()
        let projects = (try? context.fetch(descriptor)) ?? []
        return projects
            .filter { identifiers.contains($0.id) && !$0.isArchived }
            .map { ProjectEntity(id: $0.id, name: $0.name) }
    }

    @MainActor
    func suggestedEntities() async throws -> [ProjectEntity] {
        let container = try ModelContainer(for: Project.self, ProjectTask.self)
        let context = container.mainContext
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.name)])
        let projects = (try? context.fetch(descriptor)) ?? []
        return projects
            .filter { !$0.isArchived }
            .map { ProjectEntity(id: $0.id, name: $0.name) }
    }
}

// MARK: - Add Task Intent

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task"
    static var description = IntentDescription("Adds a new task to a simpleproject.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "SimpleProject")
    var project: ProjectEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickActionState.shared.pendingProjectID = project.id
        QuickActionState.shared.pendingAction = "com.claudeapp.addTask"
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NewProjectIntent(),
            phrases: [
                "Create a new project in \(.applicationName)",
                "Add a project in \(.applicationName)",
                "New project in \(.applicationName)",
                "Start a project in \(.applicationName)"
            ],
            shortTitle: "New Project",
            systemImageName: "folder.badge.plus"
        )
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "New task in \(.applicationName)",
                "Create a task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )
    }
}
