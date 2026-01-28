//
//  ComboController.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/28/26.
//
import SwiftUI
import Observation

@Observable
class ComboController {

    var capsules: [Capsule] = []
    let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func getAllCapsules() async throws {
        self.capsules = try await apiService.getAllCapsules()
    }
}

