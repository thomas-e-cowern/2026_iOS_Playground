//
//  SignInOutView.swift
//  SlideInMenu
//
//  Created by Thomas Cowern on 4/30/26.
//

import SwiftUI

struct SignInOutView: View {
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .font(.title)
            Image(systemName: "door.french.open")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    SignInOutView()
}
