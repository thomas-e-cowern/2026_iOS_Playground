//
//  TranslationModels.swift
//  AutoTranslate
//
//  Created by Thomas Cowern on 6/25/26.
//

import Foundation

struct TranslationUnit: Codable {
    var state = "translated"
    var value: String
}
