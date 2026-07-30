//
//  Employee.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import Foundation

struct Employee: Identifiable, Hashable {
    let id = UUID()
    let name: String
}


extension Employee {
    static var sampleData: [Employee] {
        [Employee(name: "Kevin Smith EMP"), Employee(name: "Leslie Knope EMP"), Employee(name: "April Ludgate EMP")]
    }
}
