//
//  CustomTabBar.swift
//  CustomAnimatedTabBar
//
//  Created by Thomas Cowern on 1/30/26.
//

import SwiftUI

enum Tab: String, CaseIterable, Hashable {
    case house
    case message
    case person
    case leaf
    case gearshape
}

struct CustomTabBar: View {
    
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                        .foregroundStyle(selectedTab == tab ? .red : .secondary)
                        .font(.system(size: 22))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.5)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.house))
}
