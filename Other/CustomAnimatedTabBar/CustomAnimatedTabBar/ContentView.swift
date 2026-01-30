//
//  ContentView.swift
//  CustomAnimatedTabBar
//
//  Created by Thomas Cowern on 1/30/26.
//
// Tutorial at https://www.youtube.com/watch?v=vzQDKYIKEb8

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: Tab = .house
    
    var body: some View {
        VStack {
            CustomTabBar(selectedTab: $selectedTab)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
