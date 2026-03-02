//
//  TaskModel.swift
//  ProjectManagerNoAI
//
//  Created by Thomas Cowern on 3/2/26.
//

import Foundation
import SwiftData

@Model
class ProjectTask {
    @Attribute var title: String
    @Attribute var isCompleted: Bool
    @Relationship var project: ProjectModel?

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
