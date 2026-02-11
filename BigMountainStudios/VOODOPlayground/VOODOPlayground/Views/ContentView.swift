//
//  ContentView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var oo = MockJokeOO()
    
    var body: some View {
        VStack {
            if oo.singleJoke?.type == "twopart" {
                TwoLinerView(setup: oo.singleJoke?.setup ?? "No setup...", delivery: oo.singleJoke?.delivery ?? "No delivery")
            } else {
                OneLinerView(joke: oo.singleJoke?.joke ?? "No one liners here...")
            }
        }
        .padding()
        .task {
            await oo.fetchOneJoke()
        }
    }
}

#Preview {
    ContentView()
}
