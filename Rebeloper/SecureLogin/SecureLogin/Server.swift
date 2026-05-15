//
//  Server.swift
//  SecureLogin
//
//  Created by Thomas Cowern on 5/15/26.
//

import Foundation

struct Server {
    static func authState(_ desired: ServerAuthState) async throws -> ServerAuthState {
        try await Task.sleep(for: .seconds(desired == .notAuthenticated ? 0 : 3))
        return desired
    }
}
