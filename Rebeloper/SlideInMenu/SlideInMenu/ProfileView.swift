//
//  ProfileView.swift
//  SlideInMenu
//
//  Created by Thomas Cowern on 4/30/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile View")
                .font(.title)
            Image(systemName: "person")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    ProfileView()
}
