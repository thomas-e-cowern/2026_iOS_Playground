//
//  LinkedListNode.swift
//  LinkedListTest
//
//  Created by Thomas Cowern on 6/9/26.
//

import Foundation

public final class LinkedListNode<Value> {
    public var value: Value
    public var next: LinkedListNode?
    
    internal init(value: Value, next: LinkedListNode? = nil) {
        self.value = value
        self.next = next
    }
}

extension LinkedListNode: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        guard let next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next)
    }
    
    
    public var debugDescription: String {
        guard let next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next)
    }
}

public struct LinkedList<Value> {
    public private(set) var head: LinkedListNode<Value>?
    public private(set) var tail: LinkedListNode<Value>?
    
    public init() {  }
    
    public var isEmpty: Bool {
        head == nil
    }
    
    public private(set) var count: Int = 0
    public var first: Value? {
        head?.value
    }
    public var last: Value? {
        tail?.value
    }
    
    @discardableResult
    public mutating func push(_ value: Value) ->LinkedListNode<Value> {
        defer { count += 1 }
        head = LinkedListNode(value: value, next: head)
        return head!
    }
    
    public mutating func append(_ value: Value) {
        guard !isEmpty else {
            push(value)
            return
        }
        defer { count += 1 }
        tail?.next = LinkedListNode(value: value)
        tail = tail?.next
    }
}
