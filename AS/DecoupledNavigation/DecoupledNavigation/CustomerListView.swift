//
//  CustomerListView.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import SwiftUI

struct CustomerListView: View {
    
    let customers: [Customer]
    
    var body: some View {
        List(customers) { customer in
            NavigationLink {
                Text(customer.name)
            } label: {
                CustomerCellView(customer: customer)
            }

        }
    }
}

#Preview {
    CustomerListView(customers: Customer.sampleData)
}
