//
//  CustomerCellView.swift
//  DecoupledNavigation
//
//  Created by Thomas Cowern on 7/30/26.
//

import SwiftUI

struct CustomerCellView: View {
    
    let customer: Customer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(customer.name)
            Text("This is where the address goes...")
        }
    }
}

#Preview {
    CustomerCellView(customer: Customer.sampleData.first ?? Customer(name: "No Customer"))
}
