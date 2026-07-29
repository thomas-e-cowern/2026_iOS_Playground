//
//  User.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/29/26.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
}
