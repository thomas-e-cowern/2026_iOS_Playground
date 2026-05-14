//
//  ContentView.swift
//  CustomLoadingButton
//
//  Created by Thomas Cowern on 4/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var state: LoadingButtonState = .idle
    
    var body: some View {
        LoadingButton(title: "loading....", state: $state) {
            animate()
        }
    }
    
    func animate() {
        state = .loading
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            state = .success
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            state = .idle
        }
    }
}

#Preview {
    ContentView()
}
