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
    
    // Breaks large requests into reasonable sizes
    private static let batchSize = 10
    
    @State private var itemCount = Double(Self.batchSize)
    @State private var totalItemCount = 0
    @State private var previewJSON = ""
    @State private var errorMessage: String?
    @State private var promptVariations: [String] = Bundle.main.decode("PromptVariations.json")
    
    let presetCategories: [PresetCategory] = Bundle.main.decode("Presets.json")
    
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
                        Menu("Add Property", systemImage: "plus") {
                            Section {
                                Button("Blank") {
                                    properties.append(PropertyDefinition())
                                }
                            }

                            ForEach(presetCategories) { category in
                                Menu(category.name, systemImage: category.symbol) {
                                    ForEach(category.presets, id: \.self) { preset in
                                        Button(preset.name) {
                                            properties.append(PropertyDefinition(from: preset))
                                        }
                                    }
                                }
                            }
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
                name: property.name.camelCased,
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
                let key = property.name.camelCased
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
