//
//  ContentView.swift
//  JSONDecoderAI
//
//  Created by Thomas Cowern on 3/26/26.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    @State private var json: JSONValue = .null

    var body: some View {
        NavigationStack {
            
            Divider()
            
            NavigationLink {
                PlatziView()
            } label: {
                Label("Platzi View", systemImage: "arrow.2.circlepath.circle")
            }

            Divider()
            
            NavigationLink {
                SpaceXView()
            } label: {
                Label("SpaceX View", systemImage: "arrow.left.circle")
            }

            Divider()

            NavigationLink {
                PlatziModelView()
            } label: {
                Label("Platzi Model View", systemImage: "shippingbox")
            }
        }
    }
}

#Preview {
    ContentView()
}
