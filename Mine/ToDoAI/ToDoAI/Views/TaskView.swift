//
//  TaskView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 3/1/26.
//

import SwiftUI
import SwiftData

struct ProjectTaskView: View {
    @State var task: ToDoProjectTask              // ProjectTask model
    // You may replace this `@State` with `@Binding` based on your data flow needs
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(task.title)                     // Display task title
                        .font(.headline)
                    if !task.detail.isEmpty {
                        Text(task.detail)                // Display optional detail
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                VStack(alignment: .trailing) {
                    CheckboxView(isCompleted: $task.completed) // Checkbox for managing task completion
                }
            }
        }
        .padding()
    }
}
#Preview {
    ProjectTaskView(task: DevData().sampleTasks.first!)
}
