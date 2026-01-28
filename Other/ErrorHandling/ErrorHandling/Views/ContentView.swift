//
//  ContentView.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(ComboController.self) private var controller
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    
                    List(controller.capsules, id: \.id) { capsule in
                        NavigationLink(destination: CapsuleView(capsule: capsule)) {
                            Text(capsule.id)
                        }
                    }
                    
                    if controller.capsuleError != nil {
                        ErrorView(errorTitle: "There was an error....")
                    }
                }
            }
            .navigationTitle("Capsules")
                .task {
                    do {
                        try await controller.getAllCapsules(withError: true)
                    } catch {
                        print("There was an error getting capsules: \(error)")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(ComboController(apiService: APIService()))
}
