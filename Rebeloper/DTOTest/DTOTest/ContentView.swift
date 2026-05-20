//
//  ContentView.swift
//  DTOTest
//
//  Created by Thomas Cowern on 5/20/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = UserViewModel()
    
    var body: some View {
        VStack {
            if let user = vm.user {
                Text(user.name)
                    .font(.title)
                Text(user.email)
                    .font(.body)
                Text(user.createdAt.formatted())
            } else {
                Text("No User Loaded")
            }
            
            Button {
                vm.loadUsers()
            } label: {
                Text("Load User")
            }
            .buttonStyle(.bordered)
            
            Button {
                vm.sendUser()
            } label: {
                Text("Send User")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
