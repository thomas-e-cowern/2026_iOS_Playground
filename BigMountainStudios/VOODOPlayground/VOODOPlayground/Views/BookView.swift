//
//  BookView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/12/26.
//

import SwiftUI

struct BookView: View {
    
    @State var oo = BookOO()
    
    var body: some View {
        List {
            Section {
                ForEach(oo.books) { book in
                    GroupBox {
                        VStack {
                            Image(systemName: "book.pages")
                            Text(book.title)
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            } header: {
                HStack {
                    Label("Books (\(oo.books.count))", systemImage: "books.vertical.fill")
                    Spacer()
                    Button {
                        oo.books.append(Book(title: "New Book", author: "New Author"))
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .headerProminence(.increased)
        .listStyle(.plain)
        .onAppear {
            oo.fetchBooks()
        }
    }
}

#Preview {
    BookView()
}
