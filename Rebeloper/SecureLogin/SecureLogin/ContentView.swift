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
                Text("")
            case .authenticating:
                Text("")
            case .authenticated:
                Text("")
            case .notAuthenticated:
                Text("")
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
