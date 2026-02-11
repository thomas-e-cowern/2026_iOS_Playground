//
//  ContentView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var oo = JokeOO()
    
    var body: some View {
        VStack {
            if let joke = oo.singleJoke {
                Text(joke.category)
            } else {
                Text("Loading joke…")
            }
        }
        .task {
            await oo.fetchJoke()
        }
    }
}

#Preview {
    ContentView()
}
