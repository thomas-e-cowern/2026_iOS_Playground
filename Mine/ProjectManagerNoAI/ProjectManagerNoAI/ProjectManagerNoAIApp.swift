//
//  ProjectManagerNoAIApp.swift
//  ProjectManagerNoAI
//
//  Created by Thomas Cowern on 3/2/26.
//

import SwiftUI
import SwiftData

@main
struct ProjectManagerNoAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: ProjectModel.self)
        }
    }
}
