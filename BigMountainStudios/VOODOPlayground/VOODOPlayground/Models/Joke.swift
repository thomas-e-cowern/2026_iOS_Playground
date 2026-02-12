//
//  JokeModel.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import Foundation

// MARK: - Joke
struct Joke: Codable, Identifiable {
    let error: Bool
    let category: String
    let type: String
    let joke: String?
    let setup: String?
    let delivery: String?
    let flags: Flags
    let safe: Bool
    let id: Int
    let lang: String
}

// MARK: - Flags
struct Flags: Codable {
    let nsfw, religious, political, racist: Bool
    let sexist, explicit: Bool
}

