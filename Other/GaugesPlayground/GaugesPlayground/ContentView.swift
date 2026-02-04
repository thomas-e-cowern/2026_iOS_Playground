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
    
    @State private var downloadProgress: CGFloat = 0.2
    
    var body: some View {
        
        let fraction = (currentValue - minValue) / (maxValue - minValue)
        
        ZStack {
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
                        .tint(
                            AngularGradient(colors: [.pink, .purple, .pink], center: .center, startAngle: .degrees(-270), endAngle: .degrees(360 * fraction))
                        )
                        .scaleEffect(2)
                    } //: End of VStack
                    .padding()
                    .tag(0)
                    
                    VStack(spacing: 100) {
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("Storage")
                        } currentValueLabel: {
                            Text("\(Int(currentValue))")
                        } minimumValueLabel: {
                            Text("\(Int(minValue))")
                        } maximumValueLabel: {
                            Text("\(Int(maxValue))")
                        }
                        .tint(.pink)
                        
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("Storage")
                        } currentValueLabel: {
                            Text("\(Int(currentValue))")
                        } minimumValueLabel: {
                            Text("\(Int(minValue))")
                        } maximumValueLabel: {
                            Text("\(Int(maxValue))")
                        }
                        .tint(Color.blue.gradient)
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("Storage")
                        } currentValueLabel: {
                            Text("\(Int(currentValue))")
                        } minimumValueLabel: {
                            Text("\(Int(minValue))")
                        } maximumValueLabel: {
                            Text("\(Int(maxValue))")
                        }
                        .tint(
                            LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .leading, endPoint: .trailing)
                        )
                        
                    }
                    .padding()
                    .tag(1)
                    
                    VStack(spacing: 100) {
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("")
                        }
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(.yellow)
                        
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("Downloading...")
                        } currentValueLabel: {
                            Text("\(Int(currentValue))%")
                                .font(.headline)
                        } minimumValueLabel: {
                            Text("\(Int(minValue))")
                        } maximumValueLabel: {
                            Text("\(Int(maxValue))")
                        }
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(.orange)
                        
                        Gauge(value: currentValue, in: minValue...maxValue) {
                            Text("")
                        } currentValueLabel: {
                            Text("")
                        } minimumValueLabel: {
                            Text("\(Int(minValue))")
                        } maximumValueLabel: {
                            Text("\(Int(maxValue))")
                        }
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(.orange)
                        
                    }
                    .padding()
                    .tag(2)
                    
                    VStack {
                        VerticalProgressBar(
                            progress: currentValue,
                            shape: RoundedRectangle(cornerRadius: 0),
                            foregroundColor: .green,
                            backgroundColor: .gray
                        )
                        .frame(width: 50, height: 200) // Set the dimensions of the progress bar
                    }
                    .padding()
                    .tag(3)
                    
                    VStack {
                        CircleProgressBar(progress: currentValue, size: 150)
                    }
                    .padding()
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
