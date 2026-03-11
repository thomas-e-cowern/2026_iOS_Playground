//
//  ClaudeAppApp.swift
//  ClaudeApp
//
//  Created by Thomas Cowern on 3/10/26.
//

import SwiftUI
import SwiftData

@main
struct ClaudeAppApp: App {
    let container: ModelContainer
    @State private var notificationManager = NotificationManager()

    init() {
        do {
            container = try ModelContainer(for: Project.self, ProjectTask.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environment(notificationManager)
                .modelContainer(container)
        }
    }
}

/// Wrapper that creates ProjectStore from the main-actor model context
struct ContentViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @State private var store: ProjectStore?

    var body: some View {
        Group {
            if let store {
                ContentView()
                    .environment(store)
            } else {
                ProgressView()
            }
        }
        .task {
            if store == nil {
                let newStore = ProjectStore(modelContext: modelContext)
                newStore.notificationManager = notificationManager
                store = newStore
                await notificationManager.requestAuthorization()
                await notificationManager.rescheduleAll(for: newStore.projects)
            }
        }
    }
}
