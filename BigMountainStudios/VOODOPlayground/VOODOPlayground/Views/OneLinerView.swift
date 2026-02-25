//
//  OneLinerView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import SwiftUI

struct OneLinerView: View {
    
    @AppStorage("darkBackground") var darkBackground: Bool = false
    
    let joke: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(joke)
                .font(.headline)
            
            Toggle(isOn: $darkBackground) {
                Text("Use Dark Background")
            }
        }
        .padding()
        .background(darkBackground ? Color.black.opacity(0.1) : Color.clear)
    }
}

#Preview {
    OneLinerView(joke: "This is where the joke goes.")
}
