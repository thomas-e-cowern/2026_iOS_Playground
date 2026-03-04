//
//  ProjectModel.swift
//  ProjectManagerNoAI
//
//  Created by Thomas Cowern on 3/2/26.
//

import Foundation
import SwiftData

@Model
class ProjectModel {
    var name: String
    var projectDescription: String
    var tasks: [ProjectTask]
    
    init(name: String, projectDescription: String, tasks: [ProjectTask] = []) {
        self.name = name
        self.projectDescription = projectDescription
        self.tasks = tasks
    }
}

@MainActor
extension ProjectModel {
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: ProjectModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(ProjectModel(name: "New Website Launch", projectDescription: "Create and launch a new marketing website."))
        container.mainContext.insert(ProjectModel(name: "Mobile App Development", projectDescription: "Develop a mobile application for both iOS and Android.", tasks: [ProjectTask(title: "Task 1", isCompleted: false)]))
        container.mainContext.insert(ProjectModel(name: "E-commerce Platform", projectDescription: "Build an online platform for selling products."))
        container.mainContext.insert(ProjectModel(name: "Social Media Campaign", projectDescription: "Launch a new social media marketing campaign."))
        container.mainContext.insert(ProjectModel(name: "Data Analytics Tool", projectDescription: "Develop a tool for analyzing data metrics."))
        container.mainContext.insert(ProjectModel(name: "SEO Optimization", projectDescription: "Optimize the company's website for search engines."))
        container.mainContext.insert(ProjectModel(name: "User Experience Research", projectDescription: "Conduct user research to improve product experience."))
        container.mainContext.insert(ProjectModel(name: "Email Marketing Campaign", projectDescription: "Design and implement an email marketing strategy."))
      
        return container
    }
}

