//
//  AsyncUIState.swift
//  LoadingStates
//
//  Created by Thomas Cowern on 1/26/26.
//

import Foundation

enum AsyncUIState: Equatable {
    case idle
    case loading
    case empty(message: String = "This is a default error....")
    case failure(message: String) // error message come from localized description
}
