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

extension View {
    func asyncOverlay<OverlayContent: View>(
        state: AsyncUIState,
        isBlocking: Bool = true,
        onRetry: (@MainActor () async -> Void)? = nil,
        @ViewBuilder overlay: @escaping (_ state: AsyncUIState, _ retry: (@MainActor () async -> Void)?) -> OverlayContent
    ) -> some View {
        modifier(StateModifier(state: state, isBlocking: isBlocking, onRetry: onRetry, overlay: overlay))
    }
}

private struct DefaultAsyncOverlay: View {
    
    let state: AsyncUIState
    let retry: (@MainActor () async -> Void)?
    
    var body: some View {
        ZStack {
            
        }
    }
}
