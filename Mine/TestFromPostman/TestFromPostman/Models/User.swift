//
//  User.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    var name: String
    var email: String
}
