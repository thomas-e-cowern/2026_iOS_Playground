//
//  PropertyWrapperView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/16/26.
//

import SwiftUI

struct PropertyWrapperView: View {
    
    @State private var newPinSeries: String = ""
    @State private var modifiedPin: String = ""
    
    var body: some View {
        
        VStack {
            
            TextField("Enter new pin series", text: $newPinSeries)
                .border(Color.gray)
                .textFieldStyle(.roundedBorder)
            
            Text(newPinSeries == "" ? "Enter a new pin series" : "New Pin Series: \(newPinSeries)")
            
            Spacer()
                .frame(height: 50)
            
            Button("Transform Pin") {
                @FourCharacters var newPin: String
                newPin = $newPinSeries.wrappedValue
                modifiedPin = newPin
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        
        
        Text("Updated Pin: \(modifiedPin)")
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
