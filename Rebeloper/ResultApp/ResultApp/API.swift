//
//  API.swift
//  ResultApp
//
//  Created by Thomas Cowern on 5/14/26.
//

import Foundation

struct API {
    
    let error: APIError?
    
    let person1 = DateConverter().randomBirthdateBetween(ageMin: 25, ageMax: 35)
    let person2 = DateConverter().randomBirthdateBetween(ageMin: 25, ageMax: 35)
    let person3 = DateConverter().randomBirthdateBetween(ageMin: 25, ageMax: 35)
    
    func fetchProfiles(completion: @escaping(Result<[Profile], Error>) -> ())  {
        let profile1 = Profile(name: "John", birthday: person1)
        let profile2 = Profile(name: "Jane", birthday: person3)
        let profile3 = Profile(name: "Bob", birthday: person3)
        
        let profiles = [profile1, profile2, profile3]
        completion(.success(profiles))
    }
}

enum APIError: Error {
    case noData
}
