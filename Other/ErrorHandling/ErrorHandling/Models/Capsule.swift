//
//  Capsule.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import Foundation

struct Capsule: Codable {
    let reuseCount, waterLandings, landLandings: Int
    let lastUpdate: String
    let launches: [String]
    let serial, status, type, id: String
    
    enum CodingKeys: String, CodingKey {
        case reuseCount = "reuse_count"
        case waterLandings = "water_landings"
        case landLandings = "land_landings"
        case lastUpdate = "last_update"
        case launches, serial, status, type, id
    }
    
    func getAllCapsules() async throws -> [Capsule] {
        
        let urlString = "https://api.spacexdata.com/v4/capsules"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Capsule].self, from: data)
        
    }
}

extension Bundle {
    func decode<T: Decodable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        // Optional: customize decoding strategies for dates or keys
        decoder.dateDecodingStrategy = .iso8601 // Example for ISO8601 dates
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
