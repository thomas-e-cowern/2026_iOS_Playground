//
//  userDTO.swift
//  DTOTest
//
//  Created by Thomas Cowern on 5/20/26.
//

import Foundation

struct UserDTO: Codable {
    let id: Int
    let name: String
    let email: String
    let createdAt: String
}
