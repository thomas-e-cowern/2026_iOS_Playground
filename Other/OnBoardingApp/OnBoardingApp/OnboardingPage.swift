//
//  OnboardingPage.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/21/26.
//

import SwiftUI

struct OnboardingPage: View {
    let image: Image
    let title: String
    let description: String
    let buttonText: String
    let action: () -> ()
    let status: String?
    
    var body: some View {
        VStack(spacing: 30) {
            image
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 5)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            
            Text(description)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 40)
                
            Button(action: action) {
                Text(buttonText)
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(GradientButton())
            
            if let status = status {
                Text(status)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPage(image: Image(systemName: "hand.wave"), title: "Onbaording Page", description: "This is the onboarding page", buttonText: "Hello", action: {}, status: "Complete")
}
