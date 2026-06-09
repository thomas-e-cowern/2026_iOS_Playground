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
