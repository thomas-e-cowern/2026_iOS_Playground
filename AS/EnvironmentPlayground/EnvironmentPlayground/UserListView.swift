//
//  UserListView.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/29/26.
//

import SwiftUI

struct UserListView: View {
    
    @Environment(\.httpClient) private var httpClient
    @State private var users: [User] = []
    
    var body: some View {
        List(users, id: \.id) { user in
            Text(user.name)
        }
        .task {
            do {
                users = try await httpClient.fetchUsers()
            } catch {
                print("There was an error: \(error)")
            }
        }
    }
}

#Preview {
    UserListView()
}
