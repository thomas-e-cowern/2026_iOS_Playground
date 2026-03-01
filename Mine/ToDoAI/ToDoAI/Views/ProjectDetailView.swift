//
//  ProjectDetailView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 3/1/26.
//

import SwiftUI

struct ProjectDetailView: View {
    
    @State var project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.title)
                .font(.largeTitle)
                .padding()
            
            ForEach(project.tasks) { task in
                TaskView(task: task)
            }
        }
    }
}

#Preview {
    ProjectDetailView(project: DevData().sampleProjects[1])
}
