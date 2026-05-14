//
//  DateConverter.swift
//  ResultApp
//
//  Created by Thomas Cowern on 5/14/26.
//

import Foundation

struct DateConverter {

    let calendar = Calendar.current
    let today = Date()

    func randomBirthdateBetween(ageMin: Int, ageMax: Int) -> Date {
        let randomAge = Int.random(in: ageMin...ageMax)
        let randomDays = Int.random(in: 0...364)

        let yearsAgo = calendar.date(byAdding: .year, value: -randomAge, to: today)!
        let finalDate = calendar.date(byAdding: .day, value: -randomDays, to: yearsAgo)!

        return finalDate
    }
}
