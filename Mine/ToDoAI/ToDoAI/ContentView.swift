//
//  ContentView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var toDos: [Project]
    
    var body: some View {
        VStack {
            List(toDos) { project in
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.title)
                        .font(.title)
                    Text(project.description)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(toDos: DevData().sampleProjects)
}
