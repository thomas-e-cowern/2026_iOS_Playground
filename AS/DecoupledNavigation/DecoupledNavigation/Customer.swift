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


extension Customer {
    static var sampleData: [Customer] {
        [Customer(name: "Kevin Smith"), Customer(name: "Leslie Knope"), Customer(name: "April Ludgate")]
    }
}
