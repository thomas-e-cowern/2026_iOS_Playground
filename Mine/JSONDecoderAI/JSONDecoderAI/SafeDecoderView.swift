//
//  SafeDecoderView.swift
//  JSONDecoderAI
//
//  Demonstrates using SafeJSONDecoder to decode JSON into standard
//  Codable models with automatic default values for missing or bad data.
//

import SwiftUI

// MARK: - Codable Models

/// Standard Codable struct — no custom init(from:) needed.
/// SafeJSONDecoder handles missing/null fields automatically.
struct SafeProduct: Codable, Identifiable {
    let id: Int
    let title: String
    let slug: String
    let price: Int
    let description: String
    let category: SafeCategory
    let images: [String]
    let creationAt: String
    let updatedAt: String
    // These fields don't exist in the JSON — SafeJSONDecoder
    // will fill them with defaults instead of crashing.
    let rating: Double
    let inStock: Bool
    let tags: [String]
}

struct SafeCategory: Codable {
    let id: Int
    let name: String
    let slug: String
    let image: String
}

// MARK: - View

struct SafeDecoderView: View {

    @State private var products: [SafeProduct] = []

    var body: some View {
        List(products) { product in

            // Overview
            Section(product.title) {
                LabeledContent("ID", value: "\(product.id)")
                LabeledContent("Price", value: "$\(product.price)")
                LabeledContent("Slug", value: product.slug)
                LabeledContent("Created", value: product.creationAt)
            }

            // Category — decoded from nested object
            Section("\(product.title) — Category") {
                LabeledContent("Name", value: product.category.name)
                LabeledContent("Slug", value: product.category.slug)
            }

            // Images — decoded from array of strings
            Section("\(product.title) — Images (\(product.images.count))") {
                ForEach(Array(product.images.enumerated()), id: \.offset) { i, url in
                    LabeledContent("Image \(i + 1)", value: url)
                        .lineLimit(1)
                }
            }

            // Description
            Section("\(product.title) — Description") {
                Text(product.description)
                    .font(.caption)
            }

            // Default values demo — these fields aren't in the JSON
            Section("\(product.title) — Default Values Demo") {
                LabeledContent("Rating (not in JSON)", value: "\(product.rating)")
                LabeledContent("In Stock (not in JSON)", value: product.inStock ? "Yes" : "No")
                LabeledContent("Tags (not in JSON)", value: product.tags.isEmpty ? "[]" : product.tags.joined(separator: ", "))
            }
        }
        .navigationTitle("Safe Decoder")
        .task {
            guard let url = Bundle.main.url(forResource: "platzi", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else { return }

            let decoder = SafeJSONDecoder()
            if let decoded = try? decoder.decode([SafeProduct].self, from: data) {
                products = decoded
            }
        }
    }
}

#Preview {
    NavigationStack {
        SafeDecoderView()
    }
}
