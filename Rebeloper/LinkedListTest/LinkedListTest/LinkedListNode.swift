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
        if tail == nil {
            tail = head
        }
        return head!
    }
    
    @discardableResult
    public mutating func append(_ value: Value) ->LinkedListNode<Value> {
        guard !isEmpty else {
            return push(value)
        }
        defer { count += 1 }
        
        // Traverses the list to find the actual last node and updates its 'next'
        var current = head
        while current?.next != nil {
            current = current?.next
        }
        current?.next = LinkedListNode(value: value)
        return tail!
    }
    
    public func node(at index: Int) -> LinkedListNode<Value>? {
        guard index >= 0 && index < count else { return nil }
        
        var currentNode = head
        var currentIndex = 0
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode!.next
            currentIndex += 1
        }
        return currentNode
    }
    
    @discardableResult
    public mutating func insert(_ value: Value, after node: LinkedListNode<Value>) -> LinkedListNode<Value> {
        
        guard tail != node else {
            return append(value)
        }
        
        defer { count += 1 }
        
        node.next = LinkedListNode(value: value, next: node.next)
        return node.next!
    }
    
    @discardableResult
    public mutating func insert(_ value: Value, at index: Int) -> LinkedListNode<Value>? {
        guard let prev = node(at: index - 1) else { return nil }
        return insert(value, after: prev)
    }
    
    func printList() {
        var current = head
        
        while current != nil {
            // Unwrapping the current node to print its value
            if let node = current {
                print(node.value, terminator: " -> ")
                current = node.next
            }
        }
        print("nil")
    }
    
    func printRecursively(node: LinkedListNode<Value>?) {
        guard let node = node else { return }
        print(node.value)
        printRecursively(node: node.next)
    }
}

extension LinkedListNode: Equatable {
    public static func == (lhs: LinkedListNode<Value>, rhs: LinkedListNode<Value>) -> Bool {
        return lhs === rhs
    }
}
