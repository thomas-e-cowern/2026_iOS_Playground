//
//  Project.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI
import SwiftData



@Model
final class Project {
    var title: String         // Title of the project
    var details: String       // Details about the project (renamed from description)
    var dueDate: Date?        // Optional due date for the project
    var tasks: [ToDoProjectTask]         // List of tasks associated with the project
    var isCompleted: Bool     // Status of the project (completed or not)
    var archivedDate: Date?   // Optional date when the project was archived

    init(title: String,
         details: String,
         dueDate: Date? = nil,
         tasks: [ToDoProjectTask] = [],
         isCompleted: Bool = false,
         archivedDate: Date? = nil) {
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.tasks = tasks
        self.isCompleted = isCompleted
        self.archivedDate = archivedDate
    }
}

