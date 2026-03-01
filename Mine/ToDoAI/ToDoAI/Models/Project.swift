//
//  Project.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI

struct Project: Identifiable {
    let id: UUID              // Unique identifier for the project
    var title: String         // Title of the project
    var description: String    // Details about the project
    var dueDate: Date?        // Optional due date for the project
    var tasks: [Task]         // List of tasks associated with the project
    var isCompleted: Bool      // Status of the project (completed or not)
    var archivedDate: Date?    // Optional date when the project was archived
}
