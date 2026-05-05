//
//  ContentView.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/4/26.
//
import FoundationModels
import SwiftUI

struct ContentView: View {
    
    @State private var properties = [PropertyDefinition]()
    @State private var prompt: String = ""
    @State private var generatedJSON = ""
    @State private var isGenerating = false
    
    var canGenerate: Bool {
        isGenerating == false
        && prompt.isEmpty == false
        && properties.isEmpty == false
        && properties.allSatisfy { $0.name.isEmpty == false }
    }
    
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
                    
                    if generatedJSON.isEmpty == false {
                        Section("Generated Output") {
                            Text(generatedJSON)
                                .fontDesign(.monospaced)
                                .textSelection(.enabled)
                        }
                    }
                }
                .navigationTitle("Mockingbird")
                .formStyle(.grouped)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if isGenerating {
                    ProgressView()
                } else {
                    Button("Generate", systemImage: "sparkles", action: generate)
                        .disabled(canGenerate == false)
                }
            }
        }
    }
    
    func buildSchema(count: Int) throws -> GenerationSchema {
        let schemaProperties = properties.map { property in
            DynamicGenerationSchema.Property(
                name: property.name,
                description: property.propertyDescription.isEmpty ? nil : property.propertyDescription,
                schema: property.type.dynamicSchema
            )
        }
        
        let itemSchema = DynamicGenerationSchema(
            name: "Item",
            properties: schemaProperties
        )
        
        let rootSchema = DynamicGenerationSchema(
            name: "Results",
            properties: [
                .init(
                    name: "items",
                    schema: .init(
                        arrayOf: itemSchema,
                        minimumElements: count,
                        maximumElements: count
                    )
                )
            ]
        )
        
        return try GenerationSchema(root: rootSchema, dependencies: [itemSchema])
    }
    
    func parseItems(_ generated: [GeneratedContent]) -> [[String: Any]] {
        generated.compactMap { item in
            var dict = [String: Any]()

            for property in properties {
                let key = property.name
                dict[key] = property.type.extractValue(from: item, key: key)
            }

            return dict.isEmpty ? nil : dict
        }
    }
    
    func makeJSON(from items: [[String: Any]]) -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys]) {
            return String(decoding: jsonData, as: UTF8.self)
        } else {
            return ""
        }
    }
    
    func generate() {
        isGenerating = true
        generatedJSON = ""

        Task {
            defer { isGenerating = false }

            do {
                let schema = try buildSchema(count: 1)
                let session = LanguageModelSession()
                let options = GenerationOptions(
                    sampling: .random(probabilityThreshold: 1, seed: .random(in: 0...1000)),
                    temperature: 1
                )
                
                var newItems = [[String: Any]]()
                
                for try await partial in session.streamResponse(to: prompt, schema: schema, options: options) {
                    guard let generated = try? partial.content.value([GeneratedContent].self, forProperty: "items") else { continue }
                    newItems = parseItems(generated)
                    generatedJSON = makeJSON(from: newItems)
                }
                
            } catch {
                generatedJSON = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
