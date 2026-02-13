//
//  Expenses.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/13/26.
//

import Foundation

struct Expense: Codable {
    let id = UUID()
    let employeeName: String
    let type: String
    let amount: Double
}
