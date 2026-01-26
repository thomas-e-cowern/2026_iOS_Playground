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
        
        func asyncOverlay(
            state: AsyncUIState,
            isBlocking: Bool = true,
            onRetry: (@MainActor () async -> Void)? = nil
    ) -> some View {
        asyncOverlay(state: state, isBlocking: isBlocking, onRetry: onRetry) { state, retry in
            DefaultAsyncOverlay(state: state, retry: retry)
        }
    }
}

private struct DefaultAsyncOverlay: View {
    
    let state: AsyncUIState
    let retry: (@MainActor () async -> Void)?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.blue.opacity(0.5))
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                switch state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                    Text("Loading...")
                        .font(.headline)
                case .empty(let message):
                    Image(systemName: "tray")
                        .font(.system(size: 30, weight: .semibold))
                    Text(message)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                case .failure(let message):
                    Image(systemName: "exclamation.triangle.fill")
                        .font(.system(size: 30, weight: .semibold))
                    Text("Something went wrong")
                        .font(.headline)
                    Text(message)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    if let retry = retry {
                        Button(action: {
                            Task {
                                await retry()
                            }
                        }) {
                            Text("Try again")
                                .foregroundColor(.blue)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                }
            }
            .padding(20)
            .frame(width: 320)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(radius: 20)
            .padding()
        }
    }
}
