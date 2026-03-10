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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
