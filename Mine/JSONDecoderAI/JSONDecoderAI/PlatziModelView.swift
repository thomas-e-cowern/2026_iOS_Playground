//
//  PlatziModelView.swift
//  JSONDecoderAI
//
//  Created by Thomas Cowern on 3/26/26.
//

import SwiftUI

// MARK: - Models

struct ProductCategory {
    let id: Int
    let name: String
    let slug: String
    let image: String
}

struct Product: Identifiable {
    let id: Int
    let title: String
    let slug: String
    let price: Int
    let description: String
    let category: ProductCategory
    let images: [String]
}

// MARK: - JSONValue → Model mapping

extension ProductCategory {
    init(json: JSONValue) {
        self.id = json["id"].intValue ?? 0
        self.name = json["name"].stringValue ?? "Unknown"
        self.slug = json["slug"].stringValue ?? ""
        self.image = json["image"].stringValue ?? ""
    }
}

extension Product {
    init(json: JSONValue) {
        self.id = json["id"].intValue ?? 0
        self.title = json["title"].stringValue ?? "Unknown"
        self.slug = json["slug"].stringValue ?? ""
        self.price = json["price"].intValue ?? 0
        self.description = json["description"].stringValue ?? ""
        self.category = ProductCategory(json: json["category"])
        self.images = json["images"].arrayValue?.compactMap(\.stringValue) ?? []
    }
}

// MARK: - View

struct PlatziModelView: View {
    
    @State private var products: [Product] = []
    
    var body: some View {
        List(products) { product in
            Section(product.title) {
                LabeledContent("ID", value: "\(product.id)")
                LabeledContent("Price", value: "$\(product.price)")
                LabeledContent("Category", value: product.category.name)
            }
            
            Section("\(product.title) — Images (\(product.images.count))") {
                HStack {
                    Spacer()
                    ForEach(Array(product.images.enumerated()), id: \.offset) { i, url in
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                    }
                    Spacer()
                }
            }
            
            Section("\(product.title) — Description") {
                Text(product.description)
                    .font(.caption)
            }
        }
        .navigationTitle("Platzi (Model)")
        .task {
            if let url = Bundle.main.url(forResource: "platzi", withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                let json = JSONValue.decode(from: data)
                products = json.arrayValue?.map { Product(json: $0) } ?? []
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlatziModelView()
    }
}
