//
//  PropertyDefinition.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/5/26.
//

import Foundation
import Observation

@Observable
class PropertyDefinition: Identifiable {
    let id = UUID()
    var name = ""
    var propertyDescription = ""
    var type: PropertyType = .string

    init() { }
}
