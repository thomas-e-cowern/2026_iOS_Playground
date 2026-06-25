//
//  StateView.swift
//  CleanUI
//
//  Created by Thomas Cowern on 6/25/26.
//

import SwiftUI

struct StateView<Content, T>: View where Content: View {
    
    let state: ViewState<T>
    let content: (T) -> Content
    let retry: () -> Void
    
    var body: some View {
        switch state {
        case .loading:
            ProgressView()
        case .success(let t):
            content(t)
        case .empty:
            Text("Empty")
        case .error(let string):
            VStack(spacing: 20) {
                Text(string)
                Button("Retry", action: retry)
            }
        }
    }
}
