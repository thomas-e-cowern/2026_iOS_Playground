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

@Observable
class PlatziStore {
    let httpClient: HTTPCLientProtocol
    
    init (httpClient: HTTPCLientProtocol) {
        self.httpClient = httpClient
    }
}

struct ContentView: View {
    
    @Environment(PlatziStore.self) private var store
    
    var body: some View {
        VStack {
            ForEach(store.httpClient.loadCustomers(), id: \.self) { customer in
                Text(customer)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(PlatziStore(httpClient: MockHttpClient()))
}





