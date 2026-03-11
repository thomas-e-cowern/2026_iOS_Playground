//
//  ContentView.swift
//  ClaudeApp
//
//  Created by Thomas Cowern on 3/10/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

#Preview {
    ContentView()
        .environment(ProjectStore.preview())
}
