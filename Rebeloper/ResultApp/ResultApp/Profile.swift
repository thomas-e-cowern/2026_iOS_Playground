//
//  Profile.swift
//  ResultApp
//
//  Created by Thomas Cowern on 5/14/26.
//

import Foundation

struct Profile {
    let name: String
    let birthday: Date
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
    }
}
