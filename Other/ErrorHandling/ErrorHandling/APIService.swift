//
//  APIService.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/28/26.
//

import Foundation
import Observation

@Observable
class APIService: Codable {
    
    func getAllCapsules() async throws -> [Capsule] {
        let urlString = "https://api.spacexdata.com/v4/capsules"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        return try JSONDecoder().decode([Capsule].self, from: data)
    }
}
