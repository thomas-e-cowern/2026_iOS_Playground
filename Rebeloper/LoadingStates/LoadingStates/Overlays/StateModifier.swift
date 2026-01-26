//
//  StateModifier.swift
//  LoadingStates
//
//  Created by Thomas Cowern on 1/26/26.
//

import SwiftUI

struct StateModifier<OverlayContent: View>: ViewModifier {
    let state: AsyncUIState
    let isBlocking: Bool
    let onRetry: (@MainActor () async -> Void)?
    @ViewBuilder let overlay: (_ state: AsyncUIState, _ retry: (@MainActor () async -> Void)?) -> OverlayContent
    
    private var shouldShowOverlay: Bool {
        switch state {
        case .idle:
            return false
        case .empty, .loading, .failure:
            return true
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if shouldShowOverlay {
                    overlay(state, onRetry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .allowsHitTesting(isBlocking)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: state)
    }
}
