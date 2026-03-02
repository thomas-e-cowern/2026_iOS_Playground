//
//  ContentView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ModelContext.self) private var modelContext
    @State private var showingAddProject = false
    @State private var newTitle: String = ""
    @State private var newDetails: String = ""

    @Query(sort: \Project.title) private var projects: [Project]

    var body: some View {
        NavigationStack {
            List(projects) { project in
                NavigationLink {
                    ProjectDetailView(project: project)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.title)
                            .font(.title)
                        Text(project.details)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                NavigationStack {
                    Form {
                        Section("New Project") {
                            TextField("Title", text: $newTitle)
                            TextField("Details", text: $newDetails, axis: .vertical)
                        }
                    }
                    .navigationTitle("Add Project")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddProject = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let project = Project(title: newTitle.isEmpty ? "Untitled" : newTitle,
                                                      details: newDetails)
                                modelContext.insert(project)
                                newTitle = ""
                                newDetails = ""
                                showingAddProject = false
                            }
                            .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Project.self)
}
