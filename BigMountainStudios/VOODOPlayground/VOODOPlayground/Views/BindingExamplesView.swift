//
//  BindingExamplesView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/18/26.
//

import SwiftUI

struct BindingExamplesView: View {
    
    @State private var examples = BindingExamples()
    
    var body: some View {
        Form {
            ColorPicker("Color Picker", selection: $examples.color)
            DatePicker("Date", selection: $examples.date)
            Slider(value: $examples.slider)
            Stepper("Value \(examples.stepper)", value: $examples.stepper)
            Text(examples.text)
            TextField("Placeholder", text: $examples.textEditor)
                .textFieldStyle(.roundedBorder)
            TextEditor(text: $examples.textEditor)
                .border(.blue)
                .frame(height: 88)
            Toggle("Toggle", isOn: $examples.toggle)
        }
    }
}

#Preview {
    BindingExamplesView()
}
