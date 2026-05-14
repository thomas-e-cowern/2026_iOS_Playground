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
    
    func fetchProfiles() {
        API().fetchProfiles { profiles in
            guard let profiles else { return }
            self.profiles = profiles
        }
    }
}
