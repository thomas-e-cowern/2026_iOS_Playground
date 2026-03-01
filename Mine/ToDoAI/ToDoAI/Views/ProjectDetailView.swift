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
        VStack {
            Text(project.title)
                .font(.largeTitle)
                .padding()
            
            ForEach(project.tasks) { task in
                Text(task.title)
            }
        }
    }
}

#Preview {
    ProjectDetailView(project: DevData().sampleProjects[1])
}
