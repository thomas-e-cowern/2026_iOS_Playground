//
//  ErrorHandlingApp.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import SwiftUI

@main
struct ErrorHandlingApp: App {
    
    private var apiService = APIService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ComboController(apiService: apiService))
        }
    }
}
