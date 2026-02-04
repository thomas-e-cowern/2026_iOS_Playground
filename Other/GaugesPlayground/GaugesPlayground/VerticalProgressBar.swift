//
//  VerticalProgressBar.swift
//  GaugesPlayground
//
//  Created by Thomas Cowern on 2/4/26.
//

import SwiftUI

struct VerticalProgressBar<Shape: SwiftUI.Shape>: View {
    let progress: Double // Value from 0.0 to 1.0
    let shape: Shape
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) { // Align fill to the bottom
                // Background shape
                shape
                    .fill(backgroundColor)
                
                // Foreground shape (the actual progress)
                shape
                    .fill(foregroundColor)
                    .frame(height: geometry.size.height * (progress / 100))
                    .animation(.linear, value: (progress / 100))
            }
        }
    }
}

#Preview {
    VerticalProgressBar(progress: 7, shape: RoundedRectangle(cornerRadius: 10))
}
