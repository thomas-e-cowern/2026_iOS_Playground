//
//  Book.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/12/26.
//

import Foundation

struct Book: Codable, Identifiable {
    var id = UUID()
    let title: String
    let author: String
}
