//
//  ProjectRowView.swift
//  ProjectManagerNoAI
//
//  Created by Thomas Cowern on 3/3/26.
//

import SwiftUI

struct ProjectRowView: View {
    
    var project: ProjectModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .font(.title)
            Text(project.projectDescription)
                .font(.caption)
        }
    }
}

#Preview {
    ProjectRowView(project: ProjectModel.mockProjects.first!)
}
