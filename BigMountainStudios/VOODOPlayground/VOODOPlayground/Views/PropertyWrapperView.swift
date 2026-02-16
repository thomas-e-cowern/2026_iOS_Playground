//
//  PropertyWrapperView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/16/26.
//

import SwiftUI

struct PropertyWrapperView: View {
    
    @State private var newPin: String = ""
    
    var body: some View {
        Text("Old Pin: 1234")
        Text("New Pin: 567890")
        
        Button("Update Pin") {
            @FourCharacters var newPin: String
            newPin = "567890"
            self.newPin = newPin
        }
        
        Text("Updated Pin: \(newPin)")
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
