import SwiftData
import Foundation

enum SharedModelContainer {
    static let appGroupIdentifier = "group.mobilesoftwareservices.ProjectSimple"

    static func create() throws -> ModelContainer {
        let schema = Schema([Project.self, ProjectTask.self])

        // Ensure the Application Support directory exists inside the
        // shared App Group container before CoreData tries to open the
        // store. Without this, the first launch on a new device/simulator
        // logs "parent directory path reported as missing" errors.
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            let supportDir = groupURL.appending(path: "Library/Application Support")
            try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        }

        let config = ModelConfiguration(
            "ProjectSimple",
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // Schema migration failed — remove the incompatible store and retry
            let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier
            )
            if let storeURL = groupURL?.appending(path: "Library/Application Support/ProjectSimple.store") {
                let related = [
                    storeURL,
                    storeURL.appendingPathExtension("shm"),
                    storeURL.appendingPathExtension("wal")
                ]
                for url in related {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            return try ModelContainer(for: schema, configurations: config)
        }
    }
}
