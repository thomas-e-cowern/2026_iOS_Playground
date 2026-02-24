//
//  WeatherView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/24/26.
//

import SwiftUI

struct WeatherView: View {
    
    @State private var oo = ForecastOO()
    
    var body: some View {
        NavigationStack {
            VStack {
                EditableWeatherSubview(forecast: oo)
                
                Divider()
                
                Text(oo.sevenDays.map { $0.day }, format: .list(type: .and, width: .narrow))
            }
            .font(.title)
            .navigationTitle("Weather")
        }
//        VStack {
//            List(oo.sevenDays) { day in
//                WeatherSubview(day: day.day, icon: day.icon)
//            }
//            
//            Button {
//                oo.updateSunday()
//                oo.updateFriday()
//            } label: {
//                Text("Update")
//                    .font(Font.title.bold())
//            }
//            .buttonStyle(.borderedProminent)
//        }
    }
}

#Preview {
    WeatherView()
}
