//
//  UserViewModel.swift
//  DTOTest
//
//  Created by Thomas Cowern on 5/20/26.
//

import Foundation

@Observable
final class UserViewModel {
    var user: User?
    
    private let mapper = UserMapper()
    
    func loadUsers() {
        let json = """
      [
        {
          "id": 1,
          "full_name": "John Smith",
          "email_address": "john.smith@example.com",
          "created_at": "2026-05-20"
        },
        {
          "id": 2,
          "full_name": "Emily Johnson",
          "email_address": "emily.johnson@example.com",
          "created_at": "2026-05-18"
        },
        {
          "id": 3,
          "full_name": "Michael Brown",
          "email_address": "michael.brown@example.com",
          "created_at": "2026-05-15"
        },
        {
          "id": 4,
          "full_name": "Sophia Davis",
          "email_address": "sophia.davis@example.com",
          "created_at": "2026-05-12"
        },
        {
          "id": 5,
          "full_name": "Daniel Wilson",
          "email_address": "daniel.wilson@example.com",
          "created_at": "2026-05-10"
        }
      ]
    """
        
        let data = Data(json.utf8)
        do {
            let dto = try JSONDecoder().decode(UserDTO.self, from: data)
            user = mapper.domain(from: dto)
        } catch  {
            print("There was an error... \(error.localizedDescription)")
        }
    }
    
    func sendUser() {
        guard let user else { return }
        
        let dto = mapper.dto(from: user)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let json = try encoder.encode(dto)
            
            print(json)
        } catch {
            print("error encoding: \(error.localizedDescription)")
        }
    }
}
