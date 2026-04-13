//
//  SafeJSONDecoder.swift
//  JSONDecoderAI
//
//  A custom Decoder that uses JSONValue as an intermediate representation
//  and returns type-appropriate default values instead of throwing when
//  fields are missing, null, or have the wrong type.
//

import Foundation

// MARK: - Defaultable Protocol

/// A type that provides a sensible default value for use when decoding fails.
protocol Defaultable {
    static var defaultValue: Self { get }
}

extension String: Defaultable {
    static var defaultValue: String { "" }
}

extension Int: Defaultable {
    static var defaultValue: Int { 0 }
}

extension Double: Defaultable {
    static var defaultValue: Double { 0.0 }
}

extension Bool: Defaultable {
    static var defaultValue: Bool { false }
}

extension Array: Defaultable {
    static var defaultValue: [Element] { [] }
}

// MARK: - SafeJSONDecoder

/// A decoder that converts JSON `Data` into `Decodable` models, substituting
/// default values for any missing, null, or type-mismatched fields.
///
/// Usage:
/// ```
/// let decoder = SafeJSONDecoder()
/// let products = try decoder.decode([Product].self, from: jsonData)
/// ```
struct SafeJSONDecoder {

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let jsonValue = try JSONValue.decodeThrowing(from: data)
        let decoder = SafeDecoder(value: jsonValue)
        return try T(from: decoder)
    }

    func decode<T: Decodable>(_ type: T.Type, from jsonValue: JSONValue) throws -> T {
        let decoder = SafeDecoder(value: jsonValue)
        return try T(from: decoder)
    }
}

// MARK: - Core Decoder

private struct SafeDecoder: Decoder {
    let value: JSONValue
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let object = value.objectValue ?? [:]
        return KeyedDecodingContainer(SafeKeyedContainer<Key>(object: object, codingPath: codingPath))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let array = value.arrayValue ?? []
        return SafeUnkeyedContainer(array: array, codingPath: codingPath)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SafeSingleValueContainer(value: value, codingPath: codingPath)
    }
}

// MARK: - Keyed Container

private struct SafeKeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let object: [String: JSONValue]
    var codingPath: [CodingKey]
    var allKeys: [Key] { object.keys.compactMap { Key(stringValue: $0) } }

    func contains(_ key: Key) -> Bool {
        object[key.stringValue] != nil
    }

    // MARK: Primitive decoding with defaults

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let val = object[key.stringValue] else { return true }
        return val.isNull
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        object[key.stringValue]?.boolValue ?? Bool.defaultValue
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        object[key.stringValue]?.stringValue ?? String.defaultValue
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        object[key.stringValue]?.doubleValue ?? Double.defaultValue
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        if let d = object[key.stringValue]?.doubleValue { return Float(d) }
        return 0.0
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        object[key.stringValue]?.intValue ?? Int.defaultValue
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        if let i = object[key.stringValue]?.intValue { return Int8(clamping: i) }
        return 0
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        if let i = object[key.stringValue]?.intValue { return Int16(clamping: i) }
        return 0
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        if let i = object[key.stringValue]?.intValue { return Int32(clamping: i) }
        return 0
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        if let i = object[key.stringValue]?.intValue { return Int64(i) }
        return 0
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        if let i = object[key.stringValue]?.intValue, i >= 0 { return UInt(i) }
        return 0
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        if let i = object[key.stringValue]?.intValue, i >= 0 { return UInt8(clamping: i) }
        return 0
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        if let i = object[key.stringValue]?.intValue, i >= 0 { return UInt16(clamping: i) }
        return 0
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        if let i = object[key.stringValue]?.intValue, i >= 0 { return UInt32(clamping: i) }
        return 0
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        if let i = object[key.stringValue]?.intValue, i >= 0 { return UInt64(i) }
        return 0
    }

    // MARK: Generic decode — handles Decodable types (nested objects, arrays, etc.)

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let childValue = object[key.stringValue] ?? .null
        let childPath = codingPath + [key]

        // For Defaultable types, catch errors and return the default
        if let defaultableType = T.self as? any Defaultable.Type {
            do {
                let decoder = SafeDecoder(value: childValue, codingPath: childPath)
                return try T(from: decoder)
            } catch {
                // swiftlint:disable:next force_cast
                return defaultableType.defaultValue as! T
            }
        }

        let decoder = SafeDecoder(value: childValue, codingPath: childPath)
        return try T(from: decoder)
    }

    // MARK: Nested containers

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        let childValue = object[key.stringValue] ?? .null
        let childObject = childValue.objectValue ?? [:]
        return KeyedDecodingContainer(SafeKeyedContainer<NestedKey>(object: childObject, codingPath: codingPath + [key]))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let childValue = object[key.stringValue] ?? .null
        let childArray = childValue.arrayValue ?? []
        return SafeUnkeyedContainer(array: childArray, codingPath: codingPath + [key])
    }

    func superDecoder() throws -> Decoder {
        SafeDecoder(value: .null, codingPath: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let childValue = object[key.stringValue] ?? .null
        return SafeDecoder(value: childValue, codingPath: codingPath + [key])
    }
}

// MARK: - Unkeyed Container

private struct SafeUnkeyedContainer: UnkeyedDecodingContainer {
    let array: [JSONValue]
    var codingPath: [CodingKey]
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex: Int = 0

    private var currentValue: JSONValue {
        guard currentIndex < array.count else { return .null }
        return array[currentIndex]
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else { return true }
        if currentValue.isNull {
            currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        defer { currentIndex += 1 }
        return currentValue.boolValue ?? Bool.defaultValue
    }

    mutating func decode(_ type: String.Type) throws -> String {
        defer { currentIndex += 1 }
        return currentValue.stringValue ?? String.defaultValue
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        defer { currentIndex += 1 }
        return currentValue.doubleValue ?? Double.defaultValue
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        defer { currentIndex += 1 }
        if let d = currentValue.doubleValue { return Float(d) }
        return 0.0
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        defer { currentIndex += 1 }
        return currentValue.intValue ?? Int.defaultValue
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue { return Int8(clamping: i) }
        return 0
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue { return Int16(clamping: i) }
        return 0
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue { return Int32(clamping: i) }
        return 0
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue { return Int64(i) }
        return 0
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue, i >= 0 { return UInt(i) }
        return 0
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue, i >= 0 { return UInt8(clamping: i) }
        return 0
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue, i >= 0 { return UInt16(clamping: i) }
        return 0
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue, i >= 0 { return UInt32(clamping: i) }
        return 0
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        defer { currentIndex += 1 }
        if let i = currentValue.intValue, i >= 0 { return UInt64(i) }
        return 0
    }

    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        defer { currentIndex += 1 }
        let decoder = SafeDecoder(value: currentValue, codingPath: codingPath)
        return try T(from: decoder)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        defer { currentIndex += 1 }
        let childObject = currentValue.objectValue ?? [:]
        return KeyedDecodingContainer(SafeKeyedContainer<NestedKey>(object: childObject, codingPath: codingPath))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        defer { currentIndex += 1 }
        let childArray = currentValue.arrayValue ?? []
        return SafeUnkeyedContainer(array: childArray, codingPath: codingPath)
    }

    mutating func superDecoder() throws -> Decoder {
        defer { currentIndex += 1 }
        return SafeDecoder(value: currentValue, codingPath: codingPath)
    }
}

// MARK: - Single Value Container

private struct SafeSingleValueContainer: SingleValueDecodingContainer {
    let value: JSONValue
    var codingPath: [CodingKey]

    func decodeNil() -> Bool { value.isNull }

    func decode(_ type: Bool.Type) throws -> Bool { value.boolValue ?? Bool.defaultValue }
    func decode(_ type: String.Type) throws -> String { value.stringValue ?? String.defaultValue }
    func decode(_ type: Double.Type) throws -> Double { value.doubleValue ?? Double.defaultValue }
    func decode(_ type: Float.Type) throws -> Float {
        if let d = value.doubleValue { return Float(d) }
        return 0.0
    }
    func decode(_ type: Int.Type) throws -> Int { value.intValue ?? Int.defaultValue }
    func decode(_ type: Int8.Type) throws -> Int8 {
        if let i = value.intValue { return Int8(clamping: i) }
        return 0
    }
    func decode(_ type: Int16.Type) throws -> Int16 {
        if let i = value.intValue { return Int16(clamping: i) }
        return 0
    }
    func decode(_ type: Int32.Type) throws -> Int32 {
        if let i = value.intValue { return Int32(clamping: i) }
        return 0
    }
    func decode(_ type: Int64.Type) throws -> Int64 {
        if let i = value.intValue { return Int64(i) }
        return 0
    }
    func decode(_ type: UInt.Type) throws -> UInt {
        if let i = value.intValue, i >= 0 { return UInt(i) }
        return 0
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        if let i = value.intValue, i >= 0 { return UInt8(clamping: i) }
        return 0
    }
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        if let i = value.intValue, i >= 0 { return UInt16(clamping: i) }
        return 0
    }
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        if let i = value.intValue, i >= 0 { return UInt32(clamping: i) }
        return 0
    }
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        if let i = value.intValue, i >= 0 { return UInt64(i) }
        return 0
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = SafeDecoder(value: value, codingPath: codingPath)
        return try T(from: decoder)
    }
}
