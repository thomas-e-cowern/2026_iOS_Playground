//
//  DevData.swift
//  ToDoAI
//
//  Created by Thomas Cowern on 2/28/26.
//

import SwiftUI
import SwiftData

struct DevData {
    let sampleProjects: [Project] = [
        Project(
            title: "Sample Project 1",
            details: "A project to explore basic functionalities.",
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Initial Setup", detail: "Set up the environment.", priority: .high, completed: false),
                ToDoProjectTask(title: "Basic UI Design", detail: "Create basic design prototypes.", priority: .normal, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            title: "Sample Project 2", 
            details: "Develop a feature for user authentication.",
            dueDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Research OAuth", detail: "Investigate OAuth for user login.", priority: .high, completed: false),
                ToDoProjectTask(title: "Implement Login", detail: "Create the login functionality.", priority: .high, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            title: "Sample Project 3",
            details: "Implement data storage solutions.",
            dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Choose Database", detail: "Select a database type.", priority: .normal, completed: false),
                ToDoProjectTask(title: "Create Models", detail: "Develop data models for storage.", priority: .normal, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            title: "Sample Project 4",
            details: "Create user profile features.",
            dueDate: Calendar.current.date(byAdding: .day, value: 35, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Profile UI", detail: "Design profile layout.", priority: .normal, completed: false),
                ToDoProjectTask(title: "Profile Logic", detail: "Implement profile editing logic.", priority: .high, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            title: "Sample Project 5",
            details: "Develop integration with third-party APIs.",
            dueDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Identify APIs", detail: "List APIs to integrate.", priority: .normal, completed: false),
                ToDoProjectTask(title: "Test API Calls", detail: "Ensure API responses are handled correctly.", priority: .high, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            title: "Sample Project 6",
            details: "Optimize app performance.",
            dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Profile Performance", detail: "Analyze performance metrics.", priority: .high, completed: false),
                ToDoProjectTask(title: "Optimize Code", detail: "Refactor inefficient code.", priority: .normal, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),
        
        Project(
            title: "Sample Project 7",
            details: "Create onboarding experience.",
            dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Design Onboarding", detail: "Plan onboarding flow.", priority: .normal, completed: false),
                ToDoProjectTask(title: "Implement Screens", detail: "Develop onboarding screens.", priority: .high, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            title: "Sample Project 8",
            details: "Set up user feedback and analytics.",
            dueDate: Calendar.current.date(byAdding: .day, value: 40, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Choose Feedback Tool", detail: "Select a tool for gathering user feedback.", priority: .normal, completed: false),
                ToDoProjectTask(title: "Integrate Analytics", detail: "Set up analytics for user behavior.", priority: .high, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            title: "Sample Project 9",
            details: "Enhance accessibility features.",
            dueDate: Calendar.current.date(byAdding: .day, value: 50, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Audit Accessibility", detail: "Review app for accessibility issues.", priority: .high, completed: false),
                ToDoProjectTask(title: "Implement Changes", detail: "Make necessary changes based on audit.", priority: .normal, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        ),

        Project(
            title: "Sample Project 10",
            details: "Prepare for app launch.",
            dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            tasks: [
                ToDoProjectTask(title: "Create Launch Plan", detail: "Develop a plan for launching the app.", priority: .high, completed: false),
                ToDoProjectTask(title: "Marketing Strategy", detail: "Plan marketing activities for the launch.", priority: .normal, completed: false)
            ],
            isCompleted: false,
            archivedDate: nil
        )
    ]
    
    let sampleTasks: [ToDoProjectTask] = [
        ToDoProjectTask(title: "Task 1", detail: "Description for task 1", priority: .high, completed: false),
        ToDoProjectTask(title: "Task 2", detail: "Description for task 2", priority: .normal, completed: false)
    ]
}

