//
//  UserMapper.swift
//  DTOTest
//
//  Created by Thomas Cowern on 5/20/26.
//

import Foundation

struct UserMapper {
    private let formatter: ISO8601DateFormatter
    
    init() {
        formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        func domain(from dto: UserDTO) -> User {
            User(id: dto.id, name: dto.name, email: dto.email, createdAt: formatter.date(from: dto.createdAt) ?? Date())
        }
        
        func dto(from domain: User) -> UserDTO {
            UserDTO(id: domain.id, name: domain.name, email: domain.email, createdAt: formatter.string(from: domain.createdAt))
        }
    }
}
