//
//  ExpensesView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/13/26.
//

import SwiftUI

struct ExpensesView: View {
    
    @State var oo = ExpensesOO()
    
    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    CardView(title: "Employee Profile") {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("Barbara Smith")
                                    .font(.title2.weight(.medium))
                                Text("IT Deparment")
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                GroupBox {
                    CardView(title: "Expenses") {
                        ForEach(oo.expenses) { expense in
                            LabeledContent(expense.type, value: expense.amount, format: .currency(code: "USD"))
                        }
                    }
                }
            }
            .onAppear {
                oo.getExpenses()
            }
        }
    }
}

#Preview {
    ExpensesView()
}
