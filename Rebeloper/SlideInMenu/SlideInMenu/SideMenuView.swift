//
//  SideMenuView.swift
//  SlideInMenu
//
//  Created by Thomas Cowern on 4/30/26.
//

import SwiftUI

struct SideMenuView: View {
    
    let actionIndex: (Int) -> ()
    
    var body: some View {
        VStack(spacing: 12) {
            Button {
                actionIndex(0)
            } label: {
                Text("Home")
            }
            
            Button {
                actionIndex(1)
            } label: {
                Text("Profile")
            }
            
            Button {
                actionIndex(2)
            } label: {
                Text("Settings")
            }

            Button {
                actionIndex(3)
            } label: {
                Text("Sign Out")
            }
        }
        .padding(.vertical)
        .font(.system(size: 25))
    }
}

#Preview {
    SideMenuView { index in
        print("Selected index: \(index)")
    }
}

