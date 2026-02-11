//
//  TwoLinerView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import SwiftUI

struct TwoLinerView: View {
    
    let setup: String
    let delivery: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(setup)
                .font(.headline)
            Text(delivery)
                .font(.headline)
        }
    }
}

#Preview {
    TwoLinerView(setup: "Why couldn't the skeleton go to the Christmas party?", delivery: "Because he had no body to go with!")
}
