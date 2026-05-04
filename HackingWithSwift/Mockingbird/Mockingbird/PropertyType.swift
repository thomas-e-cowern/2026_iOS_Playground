//
//  PropertyType.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/4/26.
//

import Foundation
import FoundationModels

enum PropertyType: String, CaseIterable, Codable, Identifiable {
    case string = "String"
    case integer = "Integer"
    case boolean = "Boolean"
    case double = "Double"

    var id: Self { self }
}
