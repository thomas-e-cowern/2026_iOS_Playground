//
//  WeatherSubview.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/24/26.
//

import SwiftUI

struct WeatherSubview: View {
    
    var day: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.blue)
            Text(day)
                .font(.title)
        }
    }
}

#Preview {
    WeatherSubview(day: "Monday", icon: "sun.max.fill")
}
