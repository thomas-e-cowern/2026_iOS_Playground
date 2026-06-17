//
//  LinkedList+Extension.swift
//  LinkedListTest
//
//  Created by Thomas Cowern on 6/15/26.
//

import Foundation

extension LinkedList: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        guard let head = head else { return "Empty List" }
        return String(describing: head)
    }
    
    public var debugDescription: String {
        guard let head = head else { return "Empty List" }
        return String(reflecting: head)
    }
}
