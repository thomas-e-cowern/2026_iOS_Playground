//
//  LoadingButtonModifier.swift
//  CustomLoadingButton
//
//  Created by Thomas Cowern on 4/27/26.
//

import SwiftUI

struct LoadingButtonModifier: ViewModifier {
    
    let title: String
    @Binding var state: LoadingButtonState
    let action: () -> ()
    var color: Color {
        switch state {
        case .idle:
                .yellow
        case .loading:
                .blue
        case .success:
                .green
        case .error(let string):
                .red
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(color, in: Capsule())
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(LoadingButtonModifier(title: "Hi yah!", state: .constant(.idle), action: {})
        )
}
