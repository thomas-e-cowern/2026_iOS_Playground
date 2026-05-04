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
    
    var dynamicSchema: DynamicGenerationSchema {
        switch self {
        case .string: .init(type: String.self)
        case .integer: .init(type: Int.self)
        case .boolean: .init(type: Bool.self)
        case .double: .init(type: Double.self)
        }
    }
    
    func extractValue(from item: GeneratedContent, key: String) -> Any? {
        switch self {
        case .string: try? item.value(String.self, forProperty: key)
        case .integer: try? item.value(Int.self, forProperty: key)
        case .boolean: try? item.value(Bool.self, forProperty: key)
        case .double: try? item.value(Double.self, forProperty: key)
        }
    }
}
