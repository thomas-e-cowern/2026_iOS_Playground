//
//  ContentView.swift
//  SecureLogin
//
//  Created by Thomas Cowern on 5/15/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var authState: AuthState = .undefined
    
    var body: some View {
        Group {
            switch authState {
            case .undefined:
                UndefinedView()
                    .task {
                        await checkAuth()
                    }
            case .authenticating:
                AuthenticatingView()
            case .authenticated:
                AuthenticatedView {
                    signOut()
                }
            case .notAuthenticated:
                NotAuthenticatedView {
                    authenticate()
                }
            }
        }
    }
    
    func checkAuth() async {
        do {
            authState = .authenticating
            let serverAuthState = try await Server.authState(.notAuthenticated)
            switch serverAuthState {
            case .authenticated:
                authState = .authenticated
            case .notAuthenticated:
                authState = .notAuthenticated
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func authenticate() {
        Task {
            do {
                authState = .authenticating
                let serverAuthState = try await Server.authState(.authenticated)
                switch serverAuthState {
                case .authenticated:
                    authState = .authenticated
                case .notAuthenticated:
                    authState = .notAuthenticated
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                authState = .authenticating
                let serverAuthState = try await Server.authState(.notAuthenticated)
                switch serverAuthState {
                case .authenticated:
                    authState = .authenticated
                case .notAuthenticated:
                    authState = .notAuthenticated
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
