//
//  ContentView.swift
//  AppleIntApp
//
//  Created by Thomas Cowern on 3/5/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    
    @State private var output = ""
    @State private var session = LanguageModelSession()
    
    var body: some View {
        VStack {
            Text(output)
            Button {
                generateJoke()
            } label: {
                Text("Generate a joke")
            }

        }
        .padding()
    }
    
    func generateJoke() {
        print("generating a new joke")
        output = "generating a new joke"
        Task {
            do {
//                let session = LanguageModelSession()
                let response = try await session.respond(to: "Please tell me a joke")
                
                output = response.content
            } catch {
                print("Something went wrong in generateJoke()")
            }
            
        }
    }
}


#Preview {
    ContentView()
}
