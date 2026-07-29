//
//  EnvironmentPlaygroundApp.swift
//  EnvironmentPlayground
//
//  Created by Thomas Cowern on 7/28/26.
//

import SwiftUI

@main
struct EnvironmentPlaygroundApp: App {
    
    @State private var store = PlatziStore(httpClient: HttpClient())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
