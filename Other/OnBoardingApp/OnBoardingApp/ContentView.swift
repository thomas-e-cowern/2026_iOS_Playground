//
//  ContentView.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/13/26.
//

import SwiftUI
import CoreLocation
import UserNotifications
import AppTrackingTransparency

struct OnboardingView: View {
    
    @State private var currentPage: Int = 0
    @State private var isOnboardingComplete: Bool = false
    @StateObject private var locationManager = LocationManager()
    @State private var notificationPermissionGranted: Bool = false
    
    private let gradientColors = [
        Color.blue, Color.purple
    ]
    
    var body: some View {
        Group {
            if isOnboardingComplete {
                MaincontentView()
            } else {
                ZStack {
                    AnimatedGradient(colors: gradientColors)
                        .ignoresSafeArea()
                    onboardingInterface
                }
                .onAppear(perform: setupLocationObserver)
            }
        }
    }
}



struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
