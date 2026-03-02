//
//  DuckAIProjectAppApp.swift
//  DuckAIProjectApp
//
//  Created by Thomas Cowern on 3/2/26.
//

import SwiftUI
import SwiftData

@main
struct ProjectManagementApp: App {
    // Use a regular let property instead of @State
    private var modelContainer: ModelContainer

    init() {
        // Initialize the model container in the initializer
        do {
            modelContainer = try ModelContainer(for: Project.self, ProjectTask.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContainer.mainContext)
        }
    }
}
