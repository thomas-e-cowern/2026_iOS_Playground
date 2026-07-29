//
//  HTTPClient.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/29/26.
//

import Foundation

struct HTTPClient {
    func fetchUsers() async throws -> [User] {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        let (data, response) = try await URLSession.shared.data(from: url!)
        return try JSONDecoder().decode([User].self, from: data)
    }
}
