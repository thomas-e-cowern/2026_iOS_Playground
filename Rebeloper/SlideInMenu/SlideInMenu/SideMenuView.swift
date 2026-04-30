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
                Text("🏠")
            }
            
            Button {
                actionIndex(1)
            } label: {
                Text("🧑‍💻")
            }
            
            Button {
                actionIndex(2)
            } label: {
                Text("⚙️")
            }
            
            Button {
                actionIndex(3)
            } label: {
                Text("🚪")
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

