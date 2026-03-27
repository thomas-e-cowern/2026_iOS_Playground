//
//  HTTPService.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid URL."
        case .encodingFailed:           return "Failed to encode request body."
        case .noData:                   return "No data received from server."
        case .decodingFailed(let e):    return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg ?? "Unknown error")"
        case .unauthorized:             return "Unauthorized. Please log in again."
        case .unknown(let e):           return e.localizedDescription
        }
    }
}

// MARK: - API Configuration

struct APIConfig {
    var defaultHeaders: [String: String]
    var timeoutInterval: TimeInterval

    static var shared = APIConfig(
        defaultHeaders: ["Content-Type": "application/json",
                         "Accept":       "application/json"],
        timeoutInterval: 30
    )

    /// Convenience: set a Bearer token for all future requests.
    mutating func setBearerToken(_ token: String?) {
        if let token {
            defaultHeaders["Authorization"] = "Bearer \(token)"
        } else {
            defaultHeaders.removeValue(forKey: "Authorization")
        }
    }
}

// MARK: - HTTPService

/// Drop-in async/await HTTP service supporting full CRUD.
/// Base URL is defined per endpoint group in APIEndpoints.swift — see AppAPI.baseURL.
/// Usage:
///   let service = HTTPService()
///   let users: [User] = try await service.get(Endpoint.Users.list)
///   let user:   User  = try await service.get(Endpoint.Users.detail(id: 1))
///   let created: User = try await service.post(Endpoint.Users.list, body: newUser)
///   let updated: User = try await service.put(Endpoint.Users.detail(id: 1), body: updatedUser)
///   let patched: User = try await service.patch(Endpoint.Users.detail(id: 1), body: ["name": "Alice"])
///   try await service.delete(Endpoint.Users.detail(id: 1))
final class HTTPService {

    private let config: APIConfig
    private let session: URLSession
    private let decoder: SafeJSONDecoder
    private let encoder: JSONEncoder

    init(config: APIConfig = .shared,
         session: URLSession = .shared,
         decoder: SafeJSONDecoder = .init(),
         encoder: JSONEncoder = .init()) {
        self.config  = config
        self.session = session
        self.decoder = decoder
        self.encoder = encoder

        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: CRUD Convenience Methods

    /// GET  — fetch a decodable resource.
    func get<Response: Decodable>(_ endpoint: any APIEndpoint,
                                   headers: [String: String] = [:]) async throws -> Response {
        try await request(method: .get, endpoint: endpoint, extraHeaders: headers)
    }

    /// POST — create a resource; returns the server response.
    func post<Body: Encodable, Response: Decodable>(_ endpoint: any APIEndpoint,
                                                     body: Body,
                                                     headers: [String: String] = [:]) async throws -> Response {
        try await request(method: .post, endpoint: endpoint, body: body, extraHeaders: headers)
    }

    /// PUT  — replace a resource entirely.
    func put<Body: Encodable, Response: Decodable>(_ endpoint: any APIEndpoint,
                                                    body: Body,
                                                    headers: [String: String] = [:]) async throws -> Response {
        try await request(method: .put, endpoint: endpoint, body: body, extraHeaders: headers)
    }

    /// PATCH — partially update a resource.
    func patch<Body: Encodable, Response: Decodable>(_ endpoint: any APIEndpoint,
                                                      body: Body,
                                                      headers: [String: String] = [:]) async throws -> Response {
        try await request(method: .patch, endpoint: endpoint, body: body, extraHeaders: headers)
    }

    /// DELETE — remove a resource (no response body expected).
    func delete(_ endpoint: any APIEndpoint,
                headers: [String: String] = [:]) async throws {
        let _: EmptyResponse = try await request(method: .delete, endpoint: endpoint, extraHeaders: headers)
    }

    /// DELETE — remove a resource and decode a response body.
    func delete<Response: Decodable>(_ endpoint: any APIEndpoint,
                                      headers: [String: String] = [:]) async throws -> Response {
        try await request(method: .delete, endpoint: endpoint, extraHeaders: headers)
    }

    // MARK: Core Request

    private func request<Response: Decodable>(
        method: HTTPMethod,
        endpoint: any APIEndpoint,
        body: (any Encodable)? = nil,
        extraHeaders: [String: String] = [:]
    ) async throws -> Response {

        // 1. Build URL
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        if let queryItems = endpoint.queryItems { components.queryItems = queryItems }
        guard let url = components.url else { throw NetworkError.invalidURL }

        // 2. Build request
        var request = URLRequest(url: url, timeoutInterval: config.timeoutInterval)
        request.httpMethod = method.rawValue

        // Merge headers (extra headers override defaults)
        var headers = config.defaultHeaders.merging(extraHeaders) { _, new in new }

        // 3. Encode body — only set Content-Type when there is a body
        if let body {
            guard let data = try? encoder.encode(body) else { throw NetworkError.encodingFailed }
            request.httpBody = data
        } else {
            headers.removeValue(forKey: "Content-Type")
        }

        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        // 4. Execute
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.unknown(error)
        }

        // 5. Validate status
        if let http = response as? HTTPURLResponse {
            switch http.statusCode {
            case 200...299: break
            case 401:       throw NetworkError.unauthorized
            default:
                let message = String(data: data, encoding: .utf8)
                throw NetworkError.serverError(statusCode: http.statusCode, message: message)
            }
        }

        // 6. Decode (handle empty responses)
        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

// MARK: - Helpers

/// Sentinel type used for DELETE calls with no response body.
private struct EmptyResponse: Codable {}
