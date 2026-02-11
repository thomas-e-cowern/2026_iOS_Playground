//
//  JokeModel.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import Foundation

struct JokeModel: Identifiable {
    var id: Int
    var joke: String
    var error: Bool
    var category: String
}
