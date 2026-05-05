//
//  PropertyRow.swift
//  Mockingbird
//
//  Created by Thomas Cowern on 5/5/26.
//

import SwiftUI

struct PropertyRow: View {
    @Bindable var property: PropertyDefinition

    var body: some View {
        TextField("Property name", text: $property.name, prompt: Text("What should this be called?"))

        TextField("Description", text: $property.propertyDescription, prompt: Text("e.g., Age in years, between 0 and 120."))

        Picker("Type", selection: $property.type) {
            ForEach(PropertyType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
}

#Preview {
    PropertyRow(property: PropertyDefinition())
}
