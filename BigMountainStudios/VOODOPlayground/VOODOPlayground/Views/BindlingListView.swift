//
//  BindlingListView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/19/26.
//

import SwiftUI

struct BindlingListView: View {
    
    @State private var ingredients = ["Celery", "Tomatoes", "Lettuce", "Onion", "Carrots"]
    
    var body: some View {
        NavigationStack {
            List($ingredients, id: \.self) { $ingredient in
                NavigationLink(ingredient) {
                    EditIngredientsSubview(ingredient: $ingredient)
                }
            }
        }
    }
}

#Preview {
    BindlingListView()
}

struct EditIngredientsSubview: View {
    
    @Binding var ingredient: String
    
    var body: some View {
        GroupBox {
            TextField("Ingredient", text: $ingredient)
        } label: {
            Text("Subview")
        }

    }
}
