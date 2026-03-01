//
//  Task.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI

struct Task {
    let id: UUID              // Unique identifier for the task
    var title: String         // Title of the task
    var description: String?   // Optional details about the task
    var dueDate: Date?        // Optional due date for the task
    var isCompleted: Bool      // Status of the task (completed or not)
    var priority: TaskPriority // Priority level of the task
    var archivedDate: Date?    // Optional date when the task was archived
}

enum TaskPriority: String {
    case low
    case medium
    case high
}
