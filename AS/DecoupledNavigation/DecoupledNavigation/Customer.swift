//
//  Customer.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import Foundation

struct Customer: Identifiable, Hashable {
    let id = UUID()
    let name: String
}
