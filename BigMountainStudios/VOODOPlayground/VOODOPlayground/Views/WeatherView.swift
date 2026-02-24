//
//  WeatherView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/24/26.
//

import SwiftUI

struct WeatherView: View {
    
    @State var oo = ForecastOO()
    
    var body: some View {
        VStack {
            List(oo.sevenDays) { day in
                HStack(spacing: 24) {
                    Image(systemName: day.icon)
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    Text(day.day)
                        .font(.title)
                }
            }
            
            Button {
                oo.updateSunday()
                oo.updateFriday()
            } label: {
                Text("Update")
                    .font(Font.title.bold())
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    WeatherView()
}
