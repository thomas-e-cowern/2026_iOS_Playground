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
    
    private var onboardingInterface: some View {
        VStack {
            pageIndicator(currentPage: $currentPage, numberOfPages: 4)
                .padding(.top, 50)
            
            TabView(selection: $currentPage) {
                welcomePage(page: 0)
                    .tag(0)
                notificationPage(page: 1)
                    .tag(1)
                locationPage(page: 2)
                    .tag(2)
                trackingPage(page: 3)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(), value: currentPage)
            
            Spacer()
            
            if currentPage == 3 {
                getStartedButton
            }
        }
    }
    
    private var welcomePage: some View {
        OnboardingPage
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
