//
//  APIEndpoints.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import Foundation

// MARK: - APIEndpoint Protocol

/// Defines a type-safe API endpoint. Conform any enum or struct to this
/// protocol to describe your routes, then pass them directly to HTTPService.
protocol APIEndpoint {
    /// The base URL for this endpoint. Defaults to `AppAPI.baseURL`.
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

// MARK: - App-wide defaults

/// Single source of truth for the base URL.
/// ← Change this value (or swap it per environment) and every endpoint updates automatically.
enum AppAPI {
    static let baseURL = "https://08374df8-ce77-4178-a3b4-627d0257e502.mock.pstmn.io"
}

extension APIEndpoint {
    /// All endpoint groups share the same base URL by default.
    /// Override `baseURL` on a specific group only if it genuinely differs.
    var baseURL: String { AppAPI.baseURL }

    /// Default implementation — most endpoints have no query parameters.
    var queryItems: [URLQueryItem]? { nil }
}

// MARK: - Endpoints

/// All API endpoints in one place.
/// Add a new case here whenever you need a new route — nowhere else.
enum Endpoint {

    // -------------------------------------------------------------------------
    // MARK: Users
    // -------------------------------------------------------------------------
    enum Users: APIEndpoint {
        case list
        case detail(id: Int)
        case search(query: String)

        var path: String {
            switch self {
            case .list:           return "/users"
            case .detail(let id): return "/users/\(id)"
            case .search:         return "/users/search"
            }
        }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .search(let query):
                return [URLQueryItem(name: "q", value: query)]
            default:
                return nil
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: Posts
    // -------------------------------------------------------------------------
    enum Posts: APIEndpoint {
        case list
        case byUser(userId: Int)
        case detail(id: Int)

        var path: String {
            switch self {
            case .list:               return "/posts"
            case .byUser(let userId): return "/users/\(userId)/posts"
            case .detail(let id):     return "/posts/\(id)"
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: Auth
    // -------------------------------------------------------------------------
    enum Auth: APIEndpoint {
        case login
        case logout
        case refresh

        var path: String {
            switch self {
            case .login:   return "/auth/login"
            case .logout:  return "/auth/logout"
            case .refresh: return "/auth/refresh"
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: Add more resource groups here following the same pattern.
    // To use a different base URL for a group, override `baseURL`:
    //
    //   enum Analytics: APIEndpoint {
    //       var baseURL: String { "https://analytics.example.com" }
    //       ...
    //   }
    // -------------------------------------------------------------------------
}

