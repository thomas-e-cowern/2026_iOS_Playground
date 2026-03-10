//
//  ClaudeAppApp.swift
//  ClaudeApp
//
//  Created by Thomas Cowern on 3/10/26.
//

import SwiftUI

@main
struct ClaudeAppApp: App {
    @State private var store = ProjectStore()
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(notificationManager)
                .task {
                    store.notificationManager = notificationManager
                    await notificationManager.requestAuthorization()
                    await notificationManager.rescheduleAll(for: store.projects)
                }
        }
    }
}
