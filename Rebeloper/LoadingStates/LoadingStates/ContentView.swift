//
//  ContentView.swift
//  LoadingStates
//
//  Created by Thomas Cowern on 1/26/26.
//

import SwiftUI

struct ContentView: View {
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
        }
    }
    
    @MainActor
    private func loadSuccess() async {
            
    }
    
    @MainActor
    private func loadEmpty() async {
        
    }
    
    @MainActor
    private func loadFail() async {
        
    }
}

#Preview {
    ContentView()
}
