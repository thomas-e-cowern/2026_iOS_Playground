//
//  OneLinerView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import SwiftUI

struct OneLinerView: View {
    
    let joke: String
    
    var body: some View {
        Text(joke)
            .font(.headline)
    }
}

#Preview {
    OneLinerView(joke: "This is where the joke goes.")
}
