//
//  HomeView.swift
//  SlideInMenu
//
//  Created by Thomas Cowern on 4/30/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home View")
                .font(.title)
            Image(systemName: "house")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    HomeView()
}
