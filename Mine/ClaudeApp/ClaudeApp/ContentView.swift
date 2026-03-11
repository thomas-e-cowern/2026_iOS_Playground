//
//  ContentView.swift
//  ClaudeApp
//
//  Created by Thomas Cowern on 3/10/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store

        TabView {
            Tab("Calendar", systemImage: "calendar") {
                CalendarView()
            }

            Tab("Projects", systemImage: "folder.fill") {
                ProjectListView()
            }

            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }

            Tab("Archive", systemImage: "archivebox") {
                ArchiveView()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK") {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
}

#Preview {
    ContentView()
        .environment(ProjectStore.preview())
}
