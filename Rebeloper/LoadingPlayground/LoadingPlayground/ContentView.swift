//
//  ContentView.swift
//  LoadingPlayground
//
//  Created by Thomas Cowern on 2/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            LoadingButton {
                try? await Task.sleep(nanoseconds: 1000 * 1_000_000)
            } label: {
                Label("Update", systemImage: "person")
            }

        }
        .padding()
    }
    
    func beSlow() async {
        try? await Task.sleep(nanoseconds: 100 * 1_000_000)
        print("Loading button pressed")
    }
}

#Preview {
    ContentView()
}
