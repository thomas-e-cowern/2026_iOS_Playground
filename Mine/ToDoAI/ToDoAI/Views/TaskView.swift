//
//  TaskView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 3/1/26.
//

import SwiftUI

struct TaskView: View {
    @State var task: Task              // Task model
    // You may replace this `@State` with `@Binding` based on your data flow needs

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        Text(task.title)                     // Display task title
                            .font(.headline)
                        if let description = task.description {
                            Text(description)                // Display optional description
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    CheckboxView(isCompleted: $task.isCompleted) // Checkbox for managing task completion
                }
            }
        }
        .padding()
    }
}
#Preview {
    TaskView(task: DevData().sampleTasks.first!)
}
