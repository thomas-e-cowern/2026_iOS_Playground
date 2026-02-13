//
//  ExpensesOO.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/13/26.
//

import SwiftUI

@Observable
class ExpensesOO {
    
    var expenses: [Expense] = []
    
    func getExpenses() {
        expenses = [
            Expense(employeeName: "Barbara Smith", type: "Flight", amount: 580.00),
            Expense(employeeName: "Barbara Smith", type: "Hotel", amount: 1600.00),
            Expense(employeeName: "Barbara Smith", type: "Meals", amount: 418.00)
        ]
    }
}
