//
//  CheckBoxView.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 3/1/26.
//

import SwiftUI

struct CheckboxView: View {
    @Binding var isCompleted: Bool    // Binding to the completed state

    var body: some View {
        Button(action: {
            isCompleted.toggle()         // Toggle the completion status
        }) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.square" : "square") // Change icon based on completion state
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isCompleted ? .green : .gray)
                Text(isCompleted ? "Completed" : "Not Completed") // Display text based on completion state
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
    }
}
 

#Preview {
    @Previewable @State var previewCompleted = true
    return CheckboxView(isCompleted: $previewCompleted)
}
