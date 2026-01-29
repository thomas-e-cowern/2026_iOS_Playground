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

fileprivate struct TabItemView<Content: View>: View {
    
    @Binding var selected: Int
    let tag: Int
    let proxy: GeometryProxy
    @ViewBuilder var content: () -> Content
    @ScaledMetric var maxHeight:CGFloat = 70
    
    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: proxy.size.width / 6)
            .frame(minHeight: 0, maxHeight: maxHeight)
            .foregroundStyle(selected == tag ? Color.accentColor : .secondary)
            .onTapGesture {
                selected = tag
            }
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
