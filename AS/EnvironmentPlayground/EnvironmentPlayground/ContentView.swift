//
//  ContentView.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/28/26.
//

import SwiftUI
import Combine

class Store: ObservableObject {
    @Published var count: Int = 0
}

struct ContentView: View {
    
    @EnvironmentObject private var store: Store
    
    var body: some View {
        VStack {
            
            let _ = Self._printChanges()
            
            VStack {
                Text("\(store.count)")
                Button("Increment") {
                    store.count += 1
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
}

struct NumberListView: View {
    @EnvironmentObject private var store: Store
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            Text("Number List View")
        }
    }
        
}



