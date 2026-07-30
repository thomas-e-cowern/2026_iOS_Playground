//
//  ContentView.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import SwiftUI

struct ContentView: View {
    
    let customers = Customer.sampleData
    let employees = Employee.sampleData
    
    var body: some View {
        VStack {
            CustomerListView(customers: customers)
                .navigationDestination(for: Customer.self) { customer in
                    Text(customer.name)
                }
            
            EmployeeListView(employees: employees)
                .navigationDestination(for: Employee.self) { employee in
                    Text("Employee List Screen: \(employee.name)")
                }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
