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
                    
                    Section("Number of Items: \(Int(itemCount))") {
                        Slider(value: $itemCount, in: Double(Self.batchSize)...1000, step: Double(Self.batchSize))
                            .labelsHidden()
                    }
                    
                    if previewJSON.isEmpty == false {
                        Section("Generated Output") {
                            Text(previewJSON)
                                .fontDesign(.monospaced)
                                .textSelection(.enabled)

                            if totalItemCount > Self.batchSize {
                                Text("and \(totalItemCount - Self.batchSize) more…")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .navigationTitle("Mockingbird")
                .formStyle(.grouped)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if generatedJSON.isEmpty == false && isGenerating == false {
                    Button("Copy to Clipboard", systemImage: "doc.on.doc") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(generatedJSON, forType: .string)
                    }
                    .labelStyle(.titleAndIcon)
                }
                
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
        errorMessage = nil
        previewJSON = ""
        totalItemCount = 0
        
        promptVariations.shuffle()

        Task {
            defer { isGenerating = false }

            do {
                var allItems = [[String: Any]]()
                let batchCount = Int(itemCount) / Self.batchSize
                let schema = try buildSchema(count: Self.batchSize)
                let session = LanguageModelSession()
                let options = GenerationOptions(
                    sampling: .random(probabilityThreshold: 1, seed: .random(in: 0...1000)),
                    temperature: 1
                )
                
                for batchIndex in 0..<batchCount {
                    let variation = promptVariations[batchIndex % promptVariations.count]
                    let instructions = "You are a mock data generator. Generate realistic, plausible sample data based on the user's description. Use only real places and names. \(variation)"

                    let session = LanguageModelSession(instructions: instructions)

                    let options = GenerationOptions(
                        sampling: .random(probabilityThreshold: 1, seed: .random(in: 0...1000)),
                        temperature: 1
                    )

                    let fullPrompt = "\(prompt)\n\nSeed: \(Int.random(in: 0...999999))"

                    var newItems = [[String: Any]]()
                    
                    for try await partial in session.streamResponse(to: fullPrompt, schema: schema, options: options) {
                        guard let generated = try? partial.content.value([GeneratedContent].self, forProperty: "items") else { continue }
                        newItems = parseItems(generated)
                        updatePreview(allItems + newItems)
                    }
                    
                    allItems.append(contentsOf: newItems)
                }
                
                generatedJSON = makeJSON(from: allItems)
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updatePreview(_ allItems: [[String: Any]]) {
        totalItemCount = allItems.count

        let previewItems = Array(allItems.prefix(Self.batchSize))
        previewJSON = makeJSON(from: previewItems)
    }
}

#Preview {
    ContentView()
}
