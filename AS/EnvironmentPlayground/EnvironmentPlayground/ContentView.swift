//
//  ContentView.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/28/26.
//

import SwiftUI

protocol HTTPCLientProtocol {
    func loadCustomers() -> [String]
}

struct HttpClient: HTTPCLientProtocol {
    func loadCustomers() -> [String] {
        [
            "Bob",
            "Alice",
            "Charlie",
        ]
    }
}

struct MockHttpClient: HTTPCLientProtocol {
    func loadCustomers() -> [String]  {
        ["Bill", "Sarah", "John", "Mary"]
    }
}

@Observable
class Store {
    var count: Int = 0
}

struct ContentView: View {
    
    @Environment(Store.self) private var store
    
    var body: some View {
        
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(Store())
}





