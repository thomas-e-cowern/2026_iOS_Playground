//
//  ContentView.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(ComboController.self) private var controller
//    @State private var capsules: [Capsule] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List(controller.capsules, id: \.id) { capsule in
                    NavigationLink(destination: CapsuleView(capsule: capsule)) {
                        Text(capsule.id)
                    }
                }
                .navigationTitle("Capsules")
                .task {
                    do {
                        try await controller.getAllCapsules()
                    } catch {
                        print("There was an error getting capsules: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ComboController(apiService: APIService()))
}
