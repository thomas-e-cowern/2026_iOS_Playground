//
//  HorizontalFillProgressCircle.swift
//  GaugesPlayground
//
//  Created by Thomas Cowern on 2/4/26.
//

import SwiftUI

struct HorizontalFillProgressCircle: View {
    let progress: Double // Value from 0.0 to 1.0
    let size: Double
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                // Background Circle (Unfilled state)
                Circle()
                    .stroke(backgroundColor)
                    .frame(width: size, height: size)
                
                // Filled Circle Part
                Circle()
                    .fill(foregroundColor)
                    .frame(width: size, height: size)
                    .mask(
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Rectangle()
                                .frame(height: size * (progress / 100))
                        }
                    )
            }
        }
        .animation(.easeInOut, value: progress)
        
        Text("Complete!")
            .font(.title2)
            .foregroundStyle(.black)
            .opacity(progress == 100 ? 1 : 0)
    }
}

#Preview {
    HorizontalFillProgressCircle(progress: 100, size: 150)
}
