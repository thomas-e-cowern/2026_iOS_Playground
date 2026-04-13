//
//  JSONValue.swift
//  TestFromPostman
//
//  Created by Thomas Cowern on 3/27/26.
//

import Foundation

// MARK: - Core Type

/// A type-safe representation of any JSON value.
enum JSONValue: Equatable, Sendable, Hashable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
}

// MARK: - Decoding

extension JSONValue {

    /// Decode JSON from raw `Data`. Returns `.null` if the data is invalid.
    static func decode(from data: Data) -> JSONValue {
        guard let raw = try? JSONSerialization.jsonObject(
            with: data,
            options: [.fragmentsAllowed]
        ) else {
            return .null
        }
        return wrap(raw)
    }

    /// Decode JSON from a `String`. Returns `.null` if the string is invalid.
    static func decode(from string: String) -> JSONValue {
        decode(from: Data(string.utf8))
    }

    /// Decode JSON from `Data`, throwing on invalid input.
    static func decodeThrowing(from data: Data) throws -> JSONValue {
        let raw = try JSONSerialization.jsonObject(
            with: data,
            options: [.fragmentsAllowed]
        )
        return wrap(raw)
    }

    /// Recursively converts Foundation's untyped JSON tree to `JSONValue`.
    private static func wrap(_ value: Any) -> JSONValue {
        switch value {
        case let string as String:
            return .string(string)
        case let number as NSNumber:
            // Use CFBooleanGetTypeID to distinguish true booleans from
            // numbers like 0 and 1, which also bridge to Bool in Swift.
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .bool(number.boolValue)
            }
            return .number(number.doubleValue)
        case let array as [Any]:
            return .array(array.map { wrap($0) })
        case let dict as [String: Any]:
            return .object(dict.mapValues { wrap($0) })
        case is NSNull:
            return .null
        default:
            return .null
        }
    }
}

// MARK: - Safe Accessors

extension JSONValue {

    /// The `String` value, or `nil` if not a string.
    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    /// The `Double` value, or `nil` if not a number.
    var doubleValue: Double? {
        if case .number(let d) = self { return d }
        return nil
    }

    /// The `Int` value, or `nil` if not a whole number.
    var intValue: Int? {
        guard case .number(let d) = self else { return nil }
        guard d == d.rounded(), !d.isInfinite else { return nil }
        return Int(exactly: d)
    }

    /// The `Bool` value, or `nil` if not a boolean.
    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }

    /// The `[JSONValue]` array, or `nil` if not an array.
    var arrayValue: [JSONValue]? {
        if case .array(let a) = self { return a }
        return nil
    }

    /// The `[String: JSONValue]` dictionary, or `nil` if not an object.
    var objectValue: [String: JSONValue]? {
        if case .object(let o) = self { return o }
        return nil
    }
}

// MARK: - Subscript Navigation

extension JSONValue {

    /// Access a value in a JSON object by key. Returns `.null` if unavailable.
    subscript(key: String) -> JSONValue {
        guard case .object(let dict) = self else { return .null }
        return dict[key] ?? .null
    }

    /// Access a value in a JSON array by index. Returns `.null` if out of bounds.
    subscript(index: Int) -> JSONValue {
        guard case .array(let arr) = self else { return .null }
        guard index >= 0, index < arr.count else { return .null }
        return arr[index]
    }
}

// MARK: - Utilities

extension JSONValue {

    /// The keys of a JSON object, or an empty array for non-objects.
    var keys: [String] {
        guard case .object(let dict) = self else { return [] }
        return Array(dict.keys)
    }

    /// The number of elements in an array or object. Returns 0 for primitives.
    var count: Int {
        switch self {
        case .array(let arr): return arr.count
        case .object(let dict): return dict.count
        default: return 0
        }
    }

    /// Whether this value is null, or an empty array/object/string.
    var isEmpty: Bool {
        switch self {
        case .null: return true
        case .string(let s): return s.isEmpty
        case .array(let arr): return arr.isEmpty
        case .object(let dict): return dict.isEmpty
        default: return false
        }
    }

    /// Whether this value is `.null`.
    var isNull: Bool {
        self == .null
    }
}

// MARK: - String Output

extension JSONValue: CustomStringConvertible {

    var description: String {
        switch self {
        case .string(let s): return "\"\(s)\""
        case .number(let d):
            if d == d.rounded(), !d.isInfinite {
                return String(format: "%.0f", d)
            }
            return String(d)
        case .bool(let b): return b ? "true" : "false"
        case .null: return "null"
        case .array(let arr):
            return "[\(arr.map(\.description).joined(separator: ", "))]"
        case .object(let dict):
            let pairs = dict.map { "\"\($0.key)\": \($0.value)" }
            return "{\(pairs.joined(separator: ", "))}"
        }
    }
}

extension JSONValue {

    /// Returns a formatted, indented JSON string.
    func prettyPrinted(indent: Int = 0) -> String {
        let pad = String(repeating: "  ", count: indent)
        let childPad = String(repeating: "  ", count: indent + 1)

        switch self {
        case .string(let s):
            return "\"\(s.escapedForJSON)\""
        case .number(let d):
            if d == d.rounded(), !d.isInfinite {
                return String(format: "%.0f", d)
            }
            return String(d)
        case .bool(let b):
            return b ? "true" : "false"
        case .null:
            return "null"
        case .array(let arr):
            if arr.isEmpty { return "[]" }
            let items = arr.map { "\(childPad)\($0.prettyPrinted(indent: indent + 1))" }
            return "[\n\(items.joined(separator: ",\n"))\n\(pad)]"
        case .object(let dict):
            if dict.isEmpty { return "{}" }
            let pairs = dict.sorted(by: { $0.key < $1.key }).map { key, value in
                "\(childPad)\"\(key)\": \(value.prettyPrinted(indent: indent + 1))"
            }
            return "{\n\(pairs.joined(separator: ",\n"))\n\(pad)}"
        }
    }
}

private extension String {
    var escapedForJSON: String {
        self.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}

// MARK: - Codable Conformance

extension JSONValue: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .number(let d): try container.encode(d)
        case .bool(let b): try container.encode(b)
        case .null: try container.encodeNil()
        case .array(let a): try container.encode(a)
        case .object(let o): try container.encode(o)
        }
    }
}
