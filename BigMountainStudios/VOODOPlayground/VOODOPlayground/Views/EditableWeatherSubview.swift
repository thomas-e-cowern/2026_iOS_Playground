//
//  EditableWeatherSubview.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/24/26.
//

import SwiftUI

struct EditableWeatherSubview: View {
    
    @Bindable var forecast: ForecastOO
    
    var body: some View {
        List($forecast.sevenDays) { $day in
            Label(
                title: {
                TextField("Day", text: $day.day)
                        .textFieldStyle(.roundedBorder)
                }, icon:  {
                    Image(systemName: day.icon)
                }
        )}
    }
}

#Preview {
    EditableWeatherSubview(forecast: ForecastOO())
}
