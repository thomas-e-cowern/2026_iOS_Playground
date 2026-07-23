//
//  ScaleEffectButton.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/23/26.
//

import SwiftUI

struct ScaleEffectButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring, value: configuration.isPressed)
    }
}
