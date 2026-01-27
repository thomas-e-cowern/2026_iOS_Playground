//
//  Capsule.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import Foundation

struct Capsule: Codable {
    let id: String
//    let reuseCount, waterLandings, landLandings: Int
//    let lastUpdate: String
//    let launches: [String]
//    let serial, status, type, id: String
    
//    enum CodingKeys: String, CodingKey {
//        case reuseCount = "reuse_count"
//        case waterLandings = "water_landings"
//        case landLandings = "land_landings"
//        case lastUpdate = "last_update"
//        case launches, serial, status, type, id
//    }
    
    static func getAllCapsules() async throws -> [Capsule] {
        
        let urlString = "https://api.spacexdata.com/v4/capsules"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        print("passed guard")
        let (data, response) = try await URLSession.shared.data(from: url)
        print("data: \(data)")
        print("response: \(response)")
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([Capsule].self, from: data)
        print(decodedData)
        return decodedData
    }
}

