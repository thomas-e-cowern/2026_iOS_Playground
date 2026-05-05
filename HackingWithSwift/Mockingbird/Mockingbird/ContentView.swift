//
//  ContentView.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/4/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var properties = [PropertyDefinition]()
    @State private var prompt: String = ""
    
    var body: some View {
        VStack {
            NavigationStack {
                Form {
                    Section("What kind of data are you making?") {
                        TextField("Enter your prompt...", text: $prompt,
                                  prompt: Text("e.g. University Students or Fictional Superheroes"), axis: .vertical)
                        .lineLimit(3...6)
                        .labelsHidden()
                    }
                    
                    ForEach(properties.enumerated(), id: \.element.id) { index, property in
                        Section("Property \(index + 1)") {
                            PropertyRow(property: property)
                            
                            Button("Remove Property", systemImage: "trash", role: .destructive) {
                                properties.removeAll { $0.id == property.id }
                            }
                        }
                    }
                    
                    Section {
                        Button("Add Property", systemImage: "plus") {
                            properties.append(PropertyDefinition())
                        }
                    }
                }
                .navigationTitle("Mockingbird")
                .formStyle(.grouped)
            }
        }
    }
}

#Preview {
    ContentView()
}
