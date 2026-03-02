//
//  ContentView.swift
//  DuckAIProjectApp
//
//  Created by Thomas Cowern on 3/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(Project.self) private var projects  // Use @Query for SwiftData models

    @State private var projectName: String = ""
    @State private var projectDescription: String = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.name).font(.headline)
                        Text(project.description).font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addProject) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addProject() {
        let newProject = Project(name: projectName, description: projectDescription)
        modelContext.insert(newProject)
        projectName = ""
        projectDescription = ""
    }
}



#Preview {
    ContentView()
}
