//
//  ProfileViewModel.swift
//  ResultApp
//
//  Created by Thomas Cowern on 5/14/26.
//

import Foundation

@Observable
class ProfileViewModel {
    var profiles: [Profile] = []
    var errorMessage: String = ""
    let api = API(error: nil)
    
    
    func fetchProfiles() {
        api.fetchProfiles { result in
            switch result {
            case .success(let profiles):
                self.profiles = profiles
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
