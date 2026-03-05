//
//  ContentView.swift
//  AppleIntApp
//
//  Created by Thomas Cowern on 3/5/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    
    @State private var input: String = ""
    @State private var output: String = ""
    @State private var session = LanguageModelSession()
    
    var body: some View {
        VStack {
            
            TextField("Enter a Prompt", text: $input)
            
            ScrollView {
                Text(output)
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Button {
//                generateJoke()
                generateReponse()
            } label: {
                Text("Generate Response")
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
    
    func generateReponse() {
        Task {
            do {
                let response = try await session.respond(to: input)
                output = response.content
            } catch {
                print("there was an error in generateResponse()")
            }
        }
    }
}


#Preview {
    ContentView()
}
