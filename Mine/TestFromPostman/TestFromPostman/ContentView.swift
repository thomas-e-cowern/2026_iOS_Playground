//
//  ContentView.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = UserViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else {
                    List {
                        ForEach(vm.users) { user in
                            VStack(alignment: .leading) {
                                Text(user.name).font(.headline)
                                Text(user.email).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            Task { await vm.delete(at: offsets) }
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task { await vm.create(name: "New User", email: "new@example.com") }
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .task { await vm.fetchAll() }
        }
    }
}

#Preview {
    ContentView()
}
