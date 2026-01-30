//
//  Leaf.swift
//  CustomAnimatedTabBar
//
//  Created by Thomas Cowern on 1/30/26.
//

import SwiftUI

struct Leaf: View {
    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            Text("Leaf View")
        }
    }
}

#Preview {
    Leaf()
}
