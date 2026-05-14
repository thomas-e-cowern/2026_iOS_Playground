//
//  ContentView.swift
//  SlideInMenu
//
//  Created by Thomas Cowern on 4/30/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showMenu: Bool = false
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            NavigationStack {
                Group {
                    switch selectedIndex {
                    case 0:
                        HomeView()
                    case 1:
                        SettingsView()
                    case 2:
                        ProfileView()
                    default:
                        EmptyView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring(Spring(response: 0.4, dampingRatio: 0.8))) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }

                    }
                }
                .disabled(showMenu)
            }
            
            if showMenu {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring) {
                            showMenu = false
                        }
                    }
            }
            
            HStack {
                VStack {
                    SideMenuView { index in
                        
                        withAnimation(.spring()) {
                            showMenu = false
                        }
                        
                        if index == 3 {
                            print("Log Out")
                        } else {
                            selectedIndex = index
                        }
                    }
                    .glassEffect()
                    
                    Spacer()
                }
                .offset(x: showMenu ? 0 : -110)
                .shadow(radius: 5)
                .transition(.move(edge: .leading))
                .padding(.leading, 10)
                .padding(.top, 50)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
