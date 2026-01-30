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
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    switch selectedTab {
                    case .house:
                        House()
                    case .message:
                        Message()
                    case .person:
                        Person()
                    case .leaf:
                        Leaf()
                    case .gearshape:
                        Gear()
                    }
                }
            }
            
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
