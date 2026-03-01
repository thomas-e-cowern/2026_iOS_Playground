//
//  DevData.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI

struct DevData {
    let sampleProjects: [Project] = [
        Project(
            id: UUID(),
            title: "Sample Project 1",
            description: "A project to explore basic functionalities.",
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Initial Setup", description: "Set up the environment.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil),
                Task(id: UUID(), title: "Basic UI Design", description: "Create basic design prototypes.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            id: UUID(),
            title: "Sample Project 2", 
            description: "Develop a feature for user authentication.",
            dueDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Research OAuth", description: "Investigate OAuth for user login.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil),
                Task(id: UUID(), title: "Implement Login", description: "Create the login functionality.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            id: UUID(),
            title: "Sample Project 3",
            description: "Implement data storage solutions.",
            dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Choose Database", description: "Select a database type.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil),
                Task(id: UUID(), title: "Create Models", description: "Develop data models for storage.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            id: UUID(),
            title: "Sample Project 4",
            description: "Create user profile features.",
            dueDate: Calendar.current.date(byAdding: .day, value: 35, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Profile UI", description: "Design profile layout.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil),
                Task(id: UUID(), title: "Profile Logic", description: "Implement profile editing logic.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            id: UUID(),
            title: "Sample Project 5",
            description: "Develop integration with third-party APIs.",
            dueDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Identify APIs", description: "List APIs to integrate.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil),
                Task(id: UUID(), title: "Test API Calls", description: "Ensure API responses are handled correctly.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            id: UUID(),
            title: "Sample Project 6",
            description: "Optimize app performance.",
            dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Profile Performance", description: "Analyze performance metrics.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil),
                Task(id: UUID(), title: "Optimize Code", description: "Refactor inefficient code.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            id: UUID(),
            title: "Sample Project 7",
            description: "Create onboarding experience.",
            dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Design Onboarding", description: "Plan onboarding flow.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil),
                Task(id: UUID(), title: "Implement Screens", description: "Develop onboarding screens.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            id: UUID(),
            title: "Sample Project 8",
            description: "Set up user feedback and analytics.",
            dueDate: Calendar.current.date(byAdding: .day, value: 40, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Choose Feedback Tool", description: "Select a tool for gathering user feedback.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil),
                Task(id: UUID(), title: "Integrate Analytics", description: "Set up analytics for user behavior.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            id: UUID(),
            title: "Sample Project 9",
            description: "Enhance accessibility features.",
            dueDate: Calendar.current.date(byAdding: .day, value: 50, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Audit Accessibility", description: "Review app for accessibility issues.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil),
                Task(id: UUID(), title: "Implement Changes", description: "Make necessary changes based on audit.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            id: UUID(),
            title: "Sample Project 10",
            description: "Prepare for app launch.",
            dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            tasks: [
                Task(id: UUID(), title: "Create Launch Plan", description: "Develop a plan for launching the app.", dueDate: nil, isCompleted: false, priority: .high, archivedDate: nil),
                Task(id: UUID(), title: "Marketing Strategy", description: "Plan marketing activities for the launch.", dueDate: nil, isCompleted: false, priority: .medium, archivedDate: nil)
            ],
            isCompleted: false,
            archivedDate: nil
        )
    ]
}
