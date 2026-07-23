//
//  AnimatedGradient.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/23/26.
//

import SwiftUI

struct AnimatedGradient: View {
    let colors: [Color]
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 0, y: 2)
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever()) {
                    start = UnitPoint(x: 1, y: -1)
                    end = UnitPoint(x: 0, y: 1)
                }
            }
    }
}
