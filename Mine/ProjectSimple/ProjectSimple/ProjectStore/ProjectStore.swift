import Foundation
import SwiftUI
import SwiftData
import CoreData
import WidgetKit
import Combine

@MainActor
@Observable
class ProjectStore {
    let modelContext: ModelContext
    var notificationManager: NotificationManager?
    private(set) var projects: [Project] = []
    var errorMessage: String?
    private var remoteChangeObserver: AnyCancellable?

    /// Bumped on every remote-change refresh so views that read it
    /// re-evaluate even when the `projects` array identity is unchanged.
    private(set) var refreshToken: Int = 0

    // MARK: - Snapshot-based Undo / Redo

    /// A lightweight snapshot of all projects, used for undo/redo.
    private var undoStack: [[ExportableProject]] = []
    private var redoStack: [[ExportableProject]] = []
    private static let maxUndoLevels = 30

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    var activeProjects: [Project] {
        projects.filter { !$0.safeIsArchived }
    }

    var archivedProjects: [Project] {
        projects.filter { $0.safeIsArchived }
    }

    var completedProjects: [Project] {
        projects.filter { !$0.safeIsArchived && $0.completionPercentage == 1.0 }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshProjects()
        cleanupDuplicateGettingStarted()
        observeRemoteChanges()
        startSyncPolling()
    }

    /// Listens for CloudKit remote-change notifications so the UI stays
    /// up to date when data arrives from another device.
    private func observeRemoteChanges() {
        remoteChangeObserver = NotificationCenter.default
            .publisher(for: .NSPersistentStoreRemoteChange)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                print("📡 NSPersistentStoreRemoteChange received")
                self?.refreshAfterRemoteChange()
            }
    }

    /// Polls for CloudKit changes on a timer as a fallback, since
    /// NSPersistentStoreRemoteChange may not always fire reliably.
    private func startSyncPolling() {
        Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                self?.pollForChanges()
            }
        }
    }

    /// Checks if the store has new data by comparing a fresh fetch
    /// against the current in-memory state.
    private func pollForChanges() {
        let freshContext = ModelContext(modelContext.container)

        let projectDescriptor = FetchDescriptor<Project>()
        let freshProjects = (try? freshContext.fetch(projectDescriptor)) ?? []

        let taskDescriptor = FetchDescriptor<ProjectTask>()
        let freshTasks = (try? freshContext.fetch(taskDescriptor)) ?? []

        // Build a simple fingerprint of the fresh data so we can detect
        // property-level changes (status, steps, title, etc.) and not
        // just count changes.
        let freshFingerprint = buildFingerprint(projects: freshProjects, tasks: freshTasks)
        let currentFingerprint = buildCurrentFingerprint()

        if freshFingerprint != currentFingerprint {
            print("📡 Poll detected changes")
            refreshAfterRemoteChange()
        }
    }

    /// Builds a string fingerprint from fresh context data.
    private func buildFingerprint(projects: [Project], tasks: [ProjectTask]) -> String {
        let projectPart = projects
            .sorted { ($0.id?.uuidString ?? "") < ($1.id?.uuidString ?? "") }
            .map { "\($0.id?.uuidString ?? ""):\($0.name ?? ""):\($0.isArchived ?? false)" }
            .joined(separator: "|")

        let taskPart = tasks
            .sorted { ($0.id?.uuidString ?? "") < ($1.id?.uuidString ?? "") }
            .map { "\($0.id?.uuidString ?? ""):\($0.status?.rawValue ?? ""):\($0.isArchived ?? false):\($0.title ?? ""):\($0.steps?.count ?? 0)" }
            .joined(separator: "|")

        return "\(projects.count);\(tasks.count);\(projectPart);\(taskPart)"
    }

    /// Builds a fingerprint from the current in-memory state.
    private func buildCurrentFingerprint() -> String {
        let allTasks = projects.flatMap { $0.safeTasks }

        let projectPart = projects
            .sorted { $0.safeID.uuidString < $1.safeID.uuidString }
            .map { "\($0.safeID.uuidString):\($0.safeName):\($0.safeIsArchived)" }
            .joined(separator: "|")

        let taskPart = allTasks
            .sorted { $0.safeID.uuidString < $1.safeID.uuidString }
            .map { "\($0.safeID.uuidString):\($0.safeStatus.rawValue):\($0.safeIsArchived):\($0.safeTitle):\($0.safeSteps.count)" }
            .joined(separator: "|")

        let totalTasks = allTasks.count
        return "\(projects.count);\(totalTasks);\(projectPart);\(taskPart)"
    }

    /// Forces the context to pick up any pending external changes
    /// (e.g. from CloudKit) and re-fetches the project list.
    func refreshAfterRemoteChange() {
        // Persist any in-flight local edits so rollback won't lose them.
        try? modelContext.save()
        // Rollback clears unsaved changes and causes the context to
        // re-fault objects on next access.
        modelContext.rollback()
        refreshProjects()
        cleanupDuplicateGettingStarted()
        // Bump the token so views that read it re-evaluate, even when
        // the same Project objects are returned with different task data.
        refreshToken += 1
        print("🔄 Refreshed (token \(refreshToken)): \(projects.count) projects, \(projects.map { $0.safeTasks.count }.reduce(0, +)) total tasks")
    }

    private func refreshProjects() {
        // Fetch projects first.
        let projectDescriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.name)])
        let fetchedProjects = (try? modelContext.fetch(projectDescriptor)) ?? []

        // Also fetch all tasks so the context has them registered and
        // up to date — this ensures task property changes from CloudKit
        // (status, steps, etc.) are reflected in the relationship arrays.
        let taskDescriptor = FetchDescriptor<ProjectTask>()
        _ = try? modelContext.fetch(taskDescriptor)

        projects = fetchedProjects
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
        refreshProjects()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Takes a snapshot of the current state before a mutation.
    /// Call this before directly modifying a SwiftData object's properties.
    func pushUndo() {
        let snapshot = projects.map { ExportableProject(from: $0) }
        undoStack.append(snapshot)
        if undoStack.count > Self.maxUndoLevels {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    /// Replaces all persisted data with the given snapshot.
    private func restore(from snapshot: [ExportableProject]) {
        // Detach tasks from projects by clearing the relationship array,
        // then delete everything. This avoids the "mandatory OTO nullify
        // inverse" batch-delete constraint violation in CoreData.
        for project in projects {
            let tasks = project.tasks ?? []
            project.tasks?.removeAll()
            for task in tasks {
                modelContext.delete(task)
            }
        }
        for project in projects {
            modelContext.delete(project)
        }
        // Re-insert from snapshot
        for exportable in snapshot {
            let project = exportable.toProject()
            modelContext.insert(project)
            for task in project.safeTasks {
                modelContext.insert(task)
            }
        }
        save()
    }

    private func scheduleNotifications() {
        guard let manager = notificationManager else { return }
        let currentProjects = activeProjects
        Task {
            await manager.rescheduleAll(for: currentProjects)
        }
    }

    // MARK: - Undo / Redo

    func undo() {
        guard let snapshot = undoStack.popLast() else { return }
        // Save current state to redo stack before restoring
        let currentSnapshot = projects.map { ExportableProject(from: $0) }
        redoStack.append(currentSnapshot)
        restore(from: snapshot)
        scheduleNotifications()
    }

    func redo() {
        guard let snapshot = redoStack.popLast() else { return }
        // Save current state to undo stack before restoring
        let currentSnapshot = projects.map { ExportableProject(from: $0) }
        undoStack.append(currentSnapshot)
        restore(from: snapshot)
        scheduleNotifications()
    }

    // MARK: - Project Operations

    func addProject(_ project: Project) {
        pushUndo()
        modelContext.insert(project)
        save()
        scheduleNotifications()
    }

    func updateProject(_ project: Project) {
        save()
        scheduleNotifications()
    }

    func deleteProject(at offsets: IndexSet) {
        pushUndo()
        let active = activeProjects
        for index in offsets {
            modelContext.delete(active[index])
        }
        save()
        scheduleNotifications()
    }

    func deleteProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }) {
            pushUndo()
            modelContext.delete(project)
            save()
        }
        scheduleNotifications()
    }

    func archiveProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }) {
            pushUndo()
            project.isArchived = true
            save()
        }
        scheduleNotifications()
    }

    func unarchiveProject(_ projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }) {
            pushUndo()
            project.isArchived = false
            save()
        }
        scheduleNotifications()
    }

    // MARK: - Task Operations

    func addTask(_ task: ProjectTask, to projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }) {
            pushUndo()
            modelContext.insert(task)
            if project.tasks == nil { project.tasks = [] }
            project.tasks?.append(task)
            save()
        }
        scheduleNotifications()
    }

    func updateTask(_ task: ProjectTask, in projectID: UUID) {
        generateNextOccurrenceIfNeeded(for: task, in: projectID)
        save()
        scheduleNotifications()
    }

    // MARK: - Recurrence

    private func generateNextOccurrenceIfNeeded(for task: ProjectTask, in projectID: UUID) {
        guard task.safeStatus == .completed,
              task.safeRecurrenceRule != .none,
              !task.safeHasGeneratedNextOccurrence,
              let nextDate = task.safeRecurrenceRule.nextDueDate(from: task.safeDueDate),
              let project = projects.first(where: { $0.safeID == projectID })
        else { return }

        let nextTask = ProjectTask(
            title: task.safeTitle,
            details: task.safeDetails,
            dueDate: nextDate,
            priority: task.safePriority,
            recurrenceRule: task.safeRecurrenceRule,
            steps: task.stepsResetForRecurrence
        )

        task.hasGeneratedNextOccurrence = true
        modelContext.insert(nextTask)
        if project.tasks == nil { project.tasks = [] }
        project.tasks?.append(nextTask)
    }

    func deleteTask(_ taskID: UUID, from projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }),
           let task = project.safeTasks.first(where: { $0.safeID == taskID }) {
            pushUndo()
            modelContext.delete(task)
            save()
        }
        scheduleNotifications()
    }

    func archiveTask(_ taskID: UUID, in projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }),
           let task = project.safeTasks.first(where: { $0.safeID == taskID }) {
            pushUndo()
            task.isArchived = true
            save()
        }
        scheduleNotifications()
    }

    func unarchiveTask(_ taskID: UUID, in projectID: UUID) {
        if let project = projects.first(where: { $0.safeID == projectID }),
           let task = project.safeTasks.first(where: { $0.safeID == taskID }) {
            pushUndo()
            task.isArchived = false
            save()
        }
        scheduleNotifications()
    }

    // MARK: - Calendar Helpers

    func tasks(for date: Date) -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                if calendar.isDate(task.safeDueDate, inSameDayAs: date) && task.safeStatus != .completed {
                    results.append((project: project, task: task))
                }
            }
        }
        return results
    }

    func overdueTasks() -> [(project: Project, task: ProjectTask)] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                if task.safeStatus != .completed && task.safeDueDate < startOfToday {
                    results.append((project: project, task: task))
                }
            }
        }
        return results.sorted { $0.task.safeDueDate < $1.task.safeDueDate }
    }

    func allTasks() -> [(project: Project, task: ProjectTask)] {
        var results: [(project: Project, task: ProjectTask)] = []
        for project in activeProjects {
            for task in project.activeTasks {
                results.append((project: project, task: task))
            }
        }
        return results
    }

    // MARK: - Export / Import

    func exportAllAsJSON() throws -> Data {
        let backup = AppBackup(projects: projects)
        return try AppBackup.encoder.encode(backup)
    }

    func exportToTemporaryFile() throws -> URL {
        let data = try exportAllAsJSON()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: .now)
        let fileName = "ProjectSimple_Backup_\(dateString).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
        return url
    }

    func importFromJSON(_ data: Data) throws -> Int {
        let backup = try AppBackup.decoder.decode(AppBackup.self, from: data)
        var importedCount = 0
        for exportableProject in backup.projects {
            let project = exportableProject.toProject()
            modelContext.insert(project)
            for task in project.safeTasks {
                modelContext.insert(task)
            }
            importedCount += 1
        }
        save()
        // Clear undo/redo stacks — import is not undoable
        undoStack.removeAll()
        redoStack.removeAll()
        scheduleNotifications()
        return importedCount
    }

    // MARK: - Preview Helper

    static func preview() -> ProjectStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Project.self, ProjectTask.self, configurations: config)
        return ProjectStore(modelContext: container.mainContext)
    }

    // MARK: - Sample Data

    private func loadSampleDataIfNeeded() {
        // With CloudKit, the local store is empty on launch and data
        // arrives asynchronously.  Only insert sample data once per
        // install, using a UserDefaults flag.
        let key = "hasLoadedSampleData"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        let descriptor = FetchDescriptor<Project>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        loadSampleData()
    }

    /// Removes ALL "Getting Started" projects that were duplicated by
    /// earlier bugs.  Runs on every remote change and at init until no
    /// more copies exist — CloudKit may keep syncing them down in waves.
    func cleanupDuplicateGettingStarted() {
        let gettingStarted = projects.filter { $0.safeName == "Getting Started" }
        guard !gettingStarted.isEmpty else { return }

        for project in gettingStarted {
            let tasks = project.tasks ?? []
            project.tasks?.removeAll()
            for task in tasks {
                modelContext.delete(task)
            }
            modelContext.delete(project)
        }
        save()
        print("🧹 Deleted \(gettingStarted.count) Getting Started project(s)")
    }

    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date.now

        let gettingStartedTasks = [
            ProjectTask(
                title: "Explore this project",
                details: "Tap this project to see its tasks. You're looking at one now! Each task has a status, priority, and due date.",
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)!,
                status: .inProgress,
                priority: .high
            ),
            ProjectTask(
                title: "Mark a task complete",
                details: "Open any task and change its status to Completed. Try it with the 'Explore this project' task once you're done reading it.",
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)!,
                status: .notStarted,
                priority: .high
            ),
            ProjectTask(
                title: "Add your own task",
                details: "Tap the + button at the top of the project to add a new task. Give it a title, due date, and priority.",
                dueDate: calendar.date(byAdding: .day, value: 3, to: today)!,
                status: .notStarted,
                priority: .medium
            ),
            ProjectTask(
                title: "Try the Search tab",
                details: "Switch to the Search tab to find tasks across all projects. You can filter by priority and category using the filter button.",
                dueDate: calendar.date(byAdding: .day, value: 4, to: today)!,
                status: .notStarted,
                priority: .medium
            ),
            ProjectTask(
                title: "Check the Calendar tab",
                details: "The Calendar tab shows tasks by due date. Tap any date to see what's due. Overdue tasks appear at the top.",
                dueDate: calendar.date(byAdding: .day, value: 5, to: today)!,
                status: .notStarted,
                priority: .low
            ),
            ProjectTask(
                title: "Create your first project",
                details: "Go back to the Projects tab and tap + to create a new project. Choose a name, color, category, and date range. Once you're comfortable, feel free to delete this Getting Started project.",
                dueDate: calendar.date(byAdding: .day, value: 7, to: today)!,
                status: .notStarted,
                priority: .low
            ),
        ]

        let gettingStarted = Project(
            name: "Getting Started",
            descriptionText: "Welcome! This project walks you through the basics of the app. Complete each task to learn how things work.",
            startDate: today,
            endDate: calendar.date(byAdding: .month, value: 1, to: today)!,
            tasks: gettingStartedTasks,
            colorName: "blue",
            category: .personal
        )

        modelContext.insert(gettingStarted)
        for task in gettingStartedTasks {
            modelContext.insert(task)
        }
        save()
    }
}
