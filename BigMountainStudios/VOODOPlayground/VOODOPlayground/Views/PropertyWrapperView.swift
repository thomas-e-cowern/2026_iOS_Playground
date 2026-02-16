//
//  PropertyWrapperView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/16/26.
//

import SwiftUI

struct PropertyWrapperView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PropertyWrapperView()
}

@propertyWrapper
struct FourCharacters {
    private var value: String = ""
    
    var wrappedValue: String {
        get { value }
        set { value = String(newValue.prefix(4)) }
    }
}
