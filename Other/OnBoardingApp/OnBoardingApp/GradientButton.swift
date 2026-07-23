//
//  GradientButton.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/23/26.
//

import SwiftUI

struct GradientButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .padding(.vertical, 15)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
