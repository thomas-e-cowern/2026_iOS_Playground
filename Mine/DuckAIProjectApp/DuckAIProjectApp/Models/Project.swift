//
//  Project.swift
//  DuckAIProjectApp
//
//  Created by Thomas Cowern on 3/2/26.
//

import Foundation
import SwiftData

@Model
class Project {
    @Attribute var name: String
    @Attribute var projectDescription: String
    @Relationship var tasks: [ProjectTask]?

    init(name: String, projectDescription: String) {
        self.name = name
        self.projectDescription = projectDescription
        self.tasks = []
    }
}
