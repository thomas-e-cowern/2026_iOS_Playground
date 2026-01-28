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
    var capsuleError: CapsuleError? = nil
    
    let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func getAllCapsules(withError: Bool) async throws {
        print("withError is \(withError)")
        if withError {
            print("There's an error....")
            capsuleError = CapsuleError.failedLoading
        } else {
            print("You should see capsules....")
            self.capsules = try await apiService.getAllCapsules()
        }
    }
    
    func clearError() {
        capsuleError = nil
    }
}

enum CapsuleError: Error {
    case failedLoading
    
    var description: String {
        switch self {
        case .failedLoading:
            return "Failed to load capsules."
        }
    }
}

