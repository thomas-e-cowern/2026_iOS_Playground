//
//  BookOO.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/12/26.
//

import Foundation

@Observable
class BookOO {
    
    var books: [Book] = []
    
    func fetchBooks() {
        print("Fetching books...")
        books = [
            Book(title: "Casino Royale", author: "Ian Fleming"),
            Book(title: "The Men Who Stare at Goats", author: "Jon Ronson"),
            Book(title: "The Bible", author: "God"),
            Book(title: "The Winds of War", author: "Herman Woulk")
        ]
    }
}
