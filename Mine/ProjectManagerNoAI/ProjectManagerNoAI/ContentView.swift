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
    
    @Query(sort: \ProjectModel.name) private var projects: [ProjectModel]
    
    @State private var orderAscending = true
    @State private var filteredText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                //            Button("Add Project") {
                //                addProject()
                //            }
                //            .font(.title)
                
                List(filteredProjects) { project in
                    ProjectRowView(project: project)
                }
                .searchable(text: $filteredText)
//                .toolbar {
//                    Button("", systemImage: "arrow.up.arrow.down.circle") {
//                        orderAscending.toggle()
//                    }
//                }
                
                //            Button("Clear Projects") {
                //                clearProjects()
                //            }
                //            .font(.title)
            }
            .navigationTitle("Projects")
        }
    }
    
    private func addProject() {
        let project = ProjectModel(name: "Project \(Int.random(in: 0...20))", projectDescription: "This is project one")
        modelContext.insert(project)
        do {
            try modelContext.save()
        } catch {
            print("Cannot save project in ContentView addProject function")
        }
    }
    
    private func clearProjects() {
        do {
            try modelContext.delete(model: ProjectModel.self)
        } catch {
            print("Failed to delete projects")
        }
    }
    
    private var sortProjects: [ProjectModel] {
        projects.sorted {
            project1, project2 in
            orderAscending ? project1.name < project2.name : project1.name > project2.name
        }
    }
    
    private var filteredProjects: [ProjectModel] {
        if filteredText.isEmpty {
            print("sortProject is empty")
            return projects
        }
        
        return projects.filter { project in
            project.name.contains(filteredText)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(ProjectModel.preview)
}
