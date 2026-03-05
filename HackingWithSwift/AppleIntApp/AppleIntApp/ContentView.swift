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
    @State private var instructions: String = ""
    
    var body: some View {
        VStack {
            
            TextField("Enter custom instructions", text: $instructions, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            
            Button {
                updateInstructions()
            } label: {
                Text("Update")
            }
            .buttonStyle(.borderedProminent)
            
            TextField("Enter a prompt", text: $input)
                .textFieldStyle(.roundedBorder)
            
            ScrollView {
                Text(output)
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Button {
//                generateJoke()
                generateReponse()
            } label: {
                Text("Generate response")
            }
            .buttonStyle(.borderedProminent)

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
//                let response = try await session.respond(to: input, options: .init(sampling: .random(probabilityThreshold: 0.5), temperature: 1))
                let stream = session.streamResponse(to: input)
                for try await chunk in stream {
                    output = chunk.content
                }
//                output = response.content
            } catch {
                print("there was an error in generateResponse()")
            }
        }
    }
    
    func updateInstructions() {
        session = LanguageModelSession(instructions: instructions)
    }
}


#Preview {
    ContentView()
}
