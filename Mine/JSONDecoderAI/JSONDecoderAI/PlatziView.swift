//
//  PlatziView.swift
//  JSONDecoderAI
//
//  Created by Thomas Cowern on 3/26/26.
//

import SwiftUI

struct PlatziView: View {
    
    @State private var json: JSONValue = .null
    
    var body: some View {
        NavigationStack {
            List {
                let products = json.arrayValue ?? []
                ForEach(Array(products.enumerated()), id: \.offset) { _, product in

                    // Overview
                    Section(product["title"].stringValue ?? "Unknown") {
                        LabeledContent("ID", value: "\(product["id"].intValue ?? 0)")
                        LabeledContent("Price", value: "$\(product["price"].intValue ?? 0)")
                        LabeledContent("Slug", value: product["slug"].stringValue ?? "N/A")
                    }

                    // Category — nested object
                    Section("\(product["title"].stringValue ?? "") — Category") {
                        let category = product["category"]
                        LabeledContent("Name", value: category["name"].stringValue ?? "N/A")
                        LabeledContent("Slug", value: category["slug"].stringValue ?? "N/A")
                    }

                    // Images — array of strings
                    Section("\(product["title"].stringValue ?? "") — Images (\(product["images"].count))") {
                        let images = product["images"].arrayValue ?? []
                        ForEach(Array(images.enumerated()), id: \.offset) { i, img in
                            if let url = img.stringValue {
                                LabeledContent("Image \(i + 1)", value: url)
                                    .lineLimit(1)
                            }
                        }
                    }

                    // Description
                    Section("\(product["title"].stringValue ?? "") — Description") {
                        Text(product["description"].stringValue ?? "No description")
                            .font(.caption)
                    }

                    // Missing key demo — safe access to keys that don't exist
                    Section("\(product["title"].stringValue ?? "") — Missing Data Demo") {
                        LabeledContent("Rating",
                            value: product["rating"].stringValue ?? "Not in JSON")
                        LabeledContent("SKU",
                            value: product["sku"].stringValue ?? "Not in JSON")
                    }
                }
            }
            .navigationTitle("Platzi Products")
        }
        .task {
            if let url = Bundle.main.url(forResource: "platzi", withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                json = JSONValue.decode(from: data)
                print(json)
            }
        }
    }
}

#Preview {
    PlatziView()
}
