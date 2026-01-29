//
//  MainView.swift
//  CustomTabView
//
//  Created by Thomas Cowern on 1/29/26.
//

import SwiftUI

fileprivate struct CustomTabItemView: View {
    
    let systemName: String
    let text: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: systemName)
                .font(.title)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal)
    }
}



struct MainView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MainView()
}
