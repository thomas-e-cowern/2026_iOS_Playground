//
//  CircleProgressBar.swift
//  GaugesPlayground
//
//  Created by Thomas Cowern on 2/4/26.
//

import SwiftUI

struct CircleProgressBar: View {
    let progress: Double // Value from 0 to 100
    let size: Double
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        
        ZStack(alignment: .center) {
            // Background shape
            Circle()
                .fill(backgroundColor)
                .frame(height: size)
            
            // Foreground shape (the actual progress)
            Circle()
                .fill(foregroundColor)
                .frame(height: size * (progress / 100))
            
            Text("Complete!")
                .font(.title2)
                .foregroundStyle(Color.white)
                .opacity(progress == 100 ? 1 : 0)
        }
    }
}

#Preview {
    CircleProgressBar(progress: 90, size: 150)
}
