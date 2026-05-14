//
//   String-CamelCase.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/5/26.
//

import Foundation

extension String {
    var camelCased: String {
        let cleaned = filter { $0.isLetter || $0.isNumber || $0 == " " }
        let words = cleaned.split(separator: " ").map(String.init)
        guard let first = words.first else { return "" }
        let rest = words.dropFirst().map(\.capitalized)
        return first.lowercased() + rest.joined()
    }
}
