//
//  AddUserView.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import SwiftUI

struct AddUserView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""

    var onCreate: (String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .navigationTitle("New User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onCreate(name, email)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    AddUserView { name, email in
        print("Create: \(name), \(email)")
    }
}
