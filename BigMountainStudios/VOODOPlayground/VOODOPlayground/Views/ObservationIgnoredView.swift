//
//  ObservationIgnoredView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/23/26.
//

import SwiftUI

struct ObservationIgnoredView: View {
    
    @State private var list = BookList()
    
    var body: some View {
        
        VStack {
            List {
                Section {
                    ForEach(list.list, id: \.self) { book in
                        Text(book)
                    }
                } header: {
                    Text("Book List")
                        .font(.title.bold())
                        .foregroundStyle(.black)
                } footer: {
                    Text("\(list.footer)")
                        .font(.headline)
                }
                
                Section {
                    Button("Add Book") {
                        list.makeUpdates()
                    }
                    .font(.title)
                    
                    Button("Just Footer Update") {
                        list.justFoooterUpdate()
                    }
                    .font(.title)
                }
            }
        }
    }
}

#Preview {
    ObservationIgnoredView()
}

@Observable
class BookList {
    var list = ["Book 1", "Book 2", "Book 3"]
    var listName = "Book List"
    
    @ObservationIgnored var footer = "3 Books"
    
    func makeUpdates() {
        list.append("Book \(list.count + 1)")
        footer = "\(list.count) books"
    }
    
    func justFoooterUpdate() {
        footer = "Read all \(list.count) books!"
    }
}
