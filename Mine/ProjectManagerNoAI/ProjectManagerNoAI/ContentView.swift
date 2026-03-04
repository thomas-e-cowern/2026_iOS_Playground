//
//  ContentView.swift
//  ProjectManagerNoAI
//
//  Created by Thomas Cowern on 3/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var projects: [ProjectModel]
    
    var body: some View {
        VStack {
            Button("Add Project") {
                addProject()
            }
            .font(.title)
            
            List(projects) { project in
                ProjectRowView(project: project)
            }
            
            Button("Clear Projects") {
                clearProjects()
            }
            .font(.title)
        }
    }
    
    private func addProject() {
        let project = ProjectModel(name: "Project \(Int.random(in: 0...20))", projectDescription: "This is project one")
        modelContext.insert(project)
    }
    
    private func clearProjects() {
        do {
            try modelContext.delete(model: ProjectModel.self)
        } catch {
            print("Failed to delete projects")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(ProjectModel.preview)
}
