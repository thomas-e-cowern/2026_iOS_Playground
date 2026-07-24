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
                MainContentView()
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
            PageIndicator(currentPage: $currentPage, numberOfPages: 4)
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
        OnboardingPage(image: Image(systemName: "hand.wave.fill"), title: "Welcome!", description: "Welcome to the app", buttonText: "Next", action: { withAnimation { currentPage = 1 }}, status: "")
    }
    
    private var notificationPage: some View {
        OnboardingPage(image: Image(systemName: "bell.fill"), title: "Notifications", description: "We need permission to send you notifications", buttonText: "Allow", action: { LocationManager.requestPermission }, status: notificationPermissionGranted ? "Allowed" : "Not allowed")
    }
    
    private var locationPage: some View {
        OnboardingPage(image: Image(systemName: "location.fill"), title: "Location", description: "We need your location to show you the best deals", buttonText: "Allow", action: { LocationManager.setVersion(1) }, status: locationManager.isAuthorized ? "Allowed" : "Not allowed")
    }
    
    private var trackingPage: some View {
        OnboardingPage(image: Image(systemName: "person.crop.circle.badge.ellipsis"), title: "Tracking", description: "We use your location to show you the best deals", buttonText: "Got it", action: { withAnimation { isOnboardingComplete = true }}, status: locationManager.isAuthorized ? "Allowed" : "Not allowed")
    }
    
    private var getStartedButton: some View {
        Button {
            isOnboardingComplete = true
        } label: {
            HStack {
                Text("Get Started")
                Image(systemName: "arrow.right.circle.fill")
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .notDetermined {
                    notificationPermissionGranted = settings.authorizationStatus == .authorized
                    currentPage = 2
                    return
                }
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    notificationPermissionGranted = granted
                    currentPage = 2
                }
            }
        }
    }
    
    private func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
    
    private func setUpLocationObserver() {
        NotificationCenter.default.addObserver(forName: .locationPermissionGranted, object: nil, queue: .main) { _ in
            if currentPage == 2 {
                currentPage = 3
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
