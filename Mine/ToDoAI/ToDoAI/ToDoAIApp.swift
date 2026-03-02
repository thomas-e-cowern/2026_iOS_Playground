//
//  ToDoAIApp.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI
import SwiftData

@main
struct ToDoAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Project.self)
        }
    }
}

