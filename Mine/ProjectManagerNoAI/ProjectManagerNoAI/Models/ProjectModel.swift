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
    
    static var mockProjects: [ProjectModel] = [
        ProjectModel(
            name: "Website Redesign",
            projectDescription: "Revamp the company's website to improve user experience and accessibility.",
            tasks: [
                ProjectTask(title: "Create wireframes", isCompleted: false),
                ProjectTask(title: "Develop frontend", isCompleted: false),
                ProjectTask(title: "User feedback collection", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Mobile App Launch",
            projectDescription: "Launch a new mobile application for iOS and Android.",
            tasks: [
                ProjectTask(title: "Market Research", isCompleted: true),
                ProjectTask(title: "Prototype development", isCompleted: false),
                ProjectTask(title: "Usability testing", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "E-commerce Platform",
            projectDescription: "Create an online platform to facilitate online shopping.",
            tasks: [
                ProjectTask(title: "Build product catalog", isCompleted: false),
                ProjectTask(title: "Implement payment gateway", isCompleted: false),
                ProjectTask(title: "Test user flow", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Social Media Strategy",
            projectDescription: "Develop a comprehensive social media strategy to increase brand awareness.",
            tasks: [
                ProjectTask(title: "Content calendar creation", isCompleted: true),
                ProjectTask(title: "Ad campaign setup", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Data Analytics Tool",
            projectDescription: "Build a tool for analyzing user data and generating reports.",
            tasks: [
                ProjectTask(title: "Define metrics", isCompleted: false),
                ProjectTask(title: "Develop backend", isCompleted: false),
                ProjectTask(title: "Create report templates", isCompleted: true)
            ]
        ),
        ProjectModel(
            name: "SEO Optimization",
            projectDescription: "Enhance website visibility on search engines.",
            tasks: [
                ProjectTask(title: "Keyword research", isCompleted: true),
                ProjectTask(title: "Content optimization", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Product Launch Campaign",
            projectDescription: "Plan and execute the launch of a new product.",
            tasks: [
                ProjectTask(title: "Create marketing materials", isCompleted: false),
                ProjectTask(title: "Launch event planning", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Virtual Conference Planning",
            projectDescription: "Organize a virtual conference for professionals.",
            tasks: [
                ProjectTask(title: "Select platform", isCompleted: true),
                ProjectTask(title: "Speaker invitations", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Cloud Migration",
            projectDescription: "Migrate company's data to a cloud provider.",
            tasks: [
                ProjectTask(title: "Analyze current infrastructure", isCompleted: true),
                ProjectTask(title: "Data transfer", isCompleted: false)
            ]
        ),
        ProjectModel(
            name: "Employee Onboarding Software",
            projectDescription: "Develop a software solution to streamline employee onboarding.",
            tasks: [
                ProjectTask(title: "Gather requirements", isCompleted: false),
                ProjectTask(title: "Design interface", isCompleted: false),
                ProjectTask(title: "User testing", isCompleted: false)
            ]
        )
    ]
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

