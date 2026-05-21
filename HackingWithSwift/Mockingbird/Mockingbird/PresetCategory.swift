//
//  PresetCategory.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/21/26.
//

import Foundation

struct PresetCategory: Codable, Identifiable {
    var id: String { name }
    var name: String
    var symbol: String
    var presets: [PresetProperty]
}
