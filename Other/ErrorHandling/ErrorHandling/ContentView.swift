//
//  ContentView.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var capsules: [Capsule] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List(capsules, id: \.id) { capsule in
                    NavigationLink(destination: CapsuleView(capsule: capsule)) {
                        Text(capsule.id)
                    }
                }
                .navigationTitle("Capsules")
                .task {
                    do {
                        capsules = try await Capsule.getAllCapsules()
                    } catch {
                        print("There was an error getting capsules")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
