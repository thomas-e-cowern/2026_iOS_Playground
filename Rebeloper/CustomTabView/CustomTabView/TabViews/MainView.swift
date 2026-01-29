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
    
    @State private var selection: Int = 0
    
    var body: some View {
        ZStack {
            switch(selection) {
            case 0:
                FeedView()
            case 1:
                InsightsView()
            case 2:
                MeditateView()
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        HStack {
                            Spacer(minLength: 0)
                            TabItemView(selected: $selection, tag: 0, proxy: proxy) {
                                CustomTabItemView(systemName: "house", text: "Home")
                            }
                            TabItemView(selected: $selection, tag: 1, proxy: proxy) {
                                CustomTabItemView(systemName: "chart.bar", text: "Insights")
                            }
                            TabItemView(selected: $selection, tag: 2, proxy: proxy) {
                                CustomTabItemView(systemName: "headphones", text: "Meditate")
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(4)
                        .background(.ultraThinMaterial)
                        Spacer(minLength: 0)
                    }
                }
            }
            .dynamicTypeSize(.large)
        }
    }
}

#Preview {
    MainView()
}
