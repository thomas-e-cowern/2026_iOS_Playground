//
//  LoadingButton.swift
//  LoadingPlayground
//
//  Created by Thomas Cowern on 2/20/26.
//

import SwiftUI

struct LoadingButton<Label: View>: View {
    
    private let action: () async -> Void
    private let label: () -> Label
    
    @State private var isLoading: Bool = false
    
    init(action: @escaping () async -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button {
            guard !isLoading else { return }
            
            isLoading = true
            print(isLoading)
            
            Task {
                await action()
                isLoading = false
            }
        } label: {
            ZStack {
                label()
                    .opacity(isLoading ? 0 : 1)
                    .padding(14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .disabled(isLoading)
    }
}

