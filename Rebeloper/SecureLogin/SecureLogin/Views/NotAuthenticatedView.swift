//
//  NotAuthenticatedView.swift
//  SecureLogin
//
//  Created by Thomas Cowern on 5/15/26.
//

import SwiftUI

struct NotAuthenticatedView: View {
    
    let action: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: "person.fill.xmark")
                .font(.largeTitle)
                .foregroundStyle(.red)
                .padding(.bottom, 20)
        } description: {
            Text("Not Authenticated")
                .font(.largeTitle)
        } actions: {
            Button("Authenticate", action: action)
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NotAuthenticatedView(action: {})
}
