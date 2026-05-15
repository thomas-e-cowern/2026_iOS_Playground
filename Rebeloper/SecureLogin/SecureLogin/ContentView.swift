//
//  ContentView.swift
//  SecureLogin
//
//  Created by Thomas Cowern on 5/15/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var authState: AuthState = .authenticated
    
    var body: some View {
        Group {
            switch authState {
            case .undefined:
                UndefinedView()
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
    
    func authenticate() {
        
    }
    
    func signOut() {
        
    }
}

#Preview {
    ContentView()
}
