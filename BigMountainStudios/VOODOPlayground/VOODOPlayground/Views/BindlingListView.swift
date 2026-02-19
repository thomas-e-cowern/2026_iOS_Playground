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
            List(ingredients, id: \.self) { ingredient in
                NavigationLink(ingredient) {
                    Text("")
                }
            }
        }
    }
}

#Preview {
    BindlingListView()
}
