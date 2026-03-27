//
//  UserVM.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import SwiftUI
internal import Combine

@MainActor
final class UserViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let service = HTTPService()

    // GET /users
    func fetchAll() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await service.get(Endpoint.Users.list)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // POST /users
    func create(name: String, email: String) async {
        let body = CreateUserRequest(name: name, email: email)
        do {
            let created: User = try await service.post(Endpoint.Users.list, body: body)
            users.append(created)
            successMessage = "\(created.name) added successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // PUT /users/:id
    func update(_ user: User) async {
        do {
            let updated: User = try await service.put(Endpoint.Users.detail(id: user.id), body: user)
            if let idx = users.firstIndex(where: { $0.id == user.id }) {
                users[idx] = updated
            }
            successMessage = "\(updated.name) updated successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // PATCH /users/:id
    func rename(_ user: User, newName: String) async {
        do {
            let patched: User = try await service.patch(Endpoint.Users.detail(id: user.id),
                                                        body: RenameUserRequest(name: newName))
            if let idx = users.firstIndex(where: { $0.id == user.id }) {
                users[idx] = patched
            }
            successMessage = "\(patched.name) renamed successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // DELETE /users/:id
    func delete(at offsets: IndexSet) async {
        for idx in offsets {
            let user = users[idx]
            do {
                let endpoint = Endpoint.Users.detail(id: user.id)
                let url = URL(string: endpoint.baseURL + endpoint.path)!
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                let (data, _) = try await URLSession.shared.data(for: request)
                print("DELETE /users/\(user.id) response: \(String(data: data, encoding: .utf8) ?? "No data")")
                let deletedName = user.name
                users.remove(at: idx)
                successMessage = "\(deletedName) deleted successfully"
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct CreateUserRequest: Encodable { let name: String; let email: String }
struct RenameUserRequest: Encodable { let name: String }
