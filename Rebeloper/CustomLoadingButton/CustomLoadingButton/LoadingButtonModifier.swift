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
        case .error:
                .red
        }
    }
    
    func body(content: Content) -> some View {
        Button {
            action()
        } label: {
            ZStack {
                switch state {
                case .idle:
                    Text(title)
                case .loading:
                    ProgressView()
                case .success:
                    Image(systemName: "checkmark")
                case .error:
                    Text("There was an error")
                }
            }
            .bold()
            .padding()
            .background(color)
            .foregroundStyle(.white)
            .clipShape(.capsule)
            .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .animation(.spring(), value: state)
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(LoadingButtonModifier(title: "Hi yah!", state: .constant(.success), action: {})
        )
}
