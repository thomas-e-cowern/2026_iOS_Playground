//
//  Language.swift
//  AutoTranslate
//
//  Created by Thomas Cowern on 6/25/26.
//

import Foundation

struct Language: Hashable, Identifiable {
    var id: String
    var name: String
    var isSelected: Bool
}
