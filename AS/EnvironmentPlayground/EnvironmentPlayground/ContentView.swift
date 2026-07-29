//
//  ContentView.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/28/26.
//

import SwiftUI

@Observable
class Store{
    var count: Int = 0
}

struct ContentView: View {
    
    @Environment(Store.self) private var store
    
    var body: some View {
        VStack {
            
            let _ = Self._printChanges()
            
            VStack {
                Text("\(store.count)")
                Button("Increment") {
                    store.count += 1
                }
                
                NumberListView()
                LightbulbView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(Store())
}

struct NumberListView: View {
    @Environment(Store.self) private var store
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            Text("Number List View")
        }
    }
        
}

struct LightbulbView: View {
//    @EnvironmentObject private var store: Store
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            Text("Lightbulb View")
        }
    }
        
}



