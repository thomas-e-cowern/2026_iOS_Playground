//
//  ContentView.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = UserViewModel()
    @State private var showingAddSheet = false
    @State private var newName = ""
    @State private var newEmail = ""
    
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
                        newName = ""
                        newEmail = ""
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $newName)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                        TextField("Email", text: $newEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .navigationTitle("New User")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                showingAddSheet = false
                                Task { await vm.create(name: newName, email: newEmail) }
                            }
                            .disabled(newName.isEmpty || newEmail.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
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
