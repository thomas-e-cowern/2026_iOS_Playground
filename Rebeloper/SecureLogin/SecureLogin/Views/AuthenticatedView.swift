//
//  AuthenticatedView.swift
//  SecureLogin
//
//  Created by Thomas Cowern on 5/15/26.
//

import SwiftUI

struct AuthenticatedView: View {
    let action: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: "person.fill.checkmark")
                .font(.largeTitle)
                .foregroundStyle(.green)
                .padding(.bottom, 20)
        } description: {
            Text("Authenticated")
                .font(.largeTitle)
        } actions: {
            Button("Sign Out", action: action)
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    AuthenticatedView(action: {})
}
