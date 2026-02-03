//
//  ContentView.swift
//  GaugesPlayground
//
//  Created by Thomas Cowern on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var minValue: Double = 0.0
    @State private var maxValue: Double = 100.0
    @State private var currentValue: Double = 60.0
    
    @State private var pageIndex: Int = 0
    
    var body: some View {
        VStack {
            Slider(value: $currentValue, in: minValue...maxValue)
                .padding(.horizontal)
            
            TabView(selection: $pageIndex) {
                VStack(spacing: 100) {
                    Gauge(value: currentValue, in: minValue...maxValue) {
                        Image(systemName: "flame")
                            .foregroundStyle(.red.opacity(currentValue))
                    } currentValueLabel: {
                        Text("\(Int(currentValue))")
                            .font(.caption)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(.blue)
                    .scaleEffect(2)
                    
                    Gauge(value: currentValue, in: minValue...maxValue) {
                        Image(systemName: "flame")
                            .foregroundStyle(.red.opacity(currentValue))
                    } currentValueLabel: {
                        Text("\(Int(currentValue))")
                            .font(.title3)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(.blue)
                    .scaleEffect(2)
                    
                    Gauge(value: currentValue, in: minValue...maxValue) {
                        Text("\(Int(currentValue))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.red.opacity(currentValue))
                    } currentValueLabel: {
                        Text("❤️")
                            .font(.system(size: currentValue * 0.35))
                            .opacity(currentValue == 0 ? 0 : 1)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(.blue)
                    .scaleEffect(2)
                }
            }
            .tabViewStyle(.page)
        }
    }
}

#Preview {
    ContentView()
}
