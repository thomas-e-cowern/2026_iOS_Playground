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
}
