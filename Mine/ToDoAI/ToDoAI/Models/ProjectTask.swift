//
//  ProjectTask.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI
import SwiftData
import Observation

@Model
final class ToDoProjectTask {
    var title: String
    var detail: String
    // Store priority as a raw value to avoid transformable ambiguity
    private var priorityRawValue: Int
    var completed: Bool

    @ObservationIgnored
    @Transient
    var priority: TaskPriorityLevel {
        get { TaskPriorityLevel(rawValue: priorityRawValue) ?? .normal }
        set { priorityRawValue = newValue.rawValue }
    }

    init(title: String,
         detail: String = "",
         priority: TaskPriorityLevel = .normal,
         completed: Bool = false) {
        self.title = title
        self.detail = detail
        self.priorityRawValue = priority.rawValue
        self.completed = completed
    }
}

enum TaskPriorityLevel: Int, Codable, CaseIterable, Identifiable {
    case low
    case normal
    case high

    var id: Int { rawValue }
}

