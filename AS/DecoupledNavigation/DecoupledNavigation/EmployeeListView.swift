//
//  EmployeeListView.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import SwiftUI

struct EmployeeListView: View {
    
    let employees: [Employee]
    
    var body: some View {
          List(employees) { employee in
              Text(employee.name)
        }
    }
}

#Preview {
    EmployeeListView(employees: Employee.sampleData)
}
