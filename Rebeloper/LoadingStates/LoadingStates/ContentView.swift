//
//  ContentView.swift
//  LoadingStates
//
//  Created by Thomas Cowern on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var state: AsyncUIState = .idle
    
    var body: some View {
        VStack {
            List {
                Button("Load (Success -> Idle)") {
                    Task {
                        await loadSuccess()
                    }
                }
                
                Button("Load (Empty)") {
                    Task {
                        await loadEmpty()
                    }
                }
                
                Button("Load (Fail)") {
                    Task {
                        await loadFail()
                    }
                }
            }
            .navigationTitle("Loading States")
            .asyncOverlay(state: state) {
                await loadSuccess()
            }
        }
    }
    
    @MainActor
    private func loadSuccess() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        state = .idle
    }
    
    @MainActor
    private func loadEmpty() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        state = .empty(message: "There are no items to load...")
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        state = .idle
    }
    
    @MainActor
    private func loadFail() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        state = .failure(message: "There was no way to get the data...")
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
