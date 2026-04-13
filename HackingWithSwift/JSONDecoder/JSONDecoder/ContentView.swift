//
//  ContentView.swift
//  JSONDecoder
//
//  Created by Thomas Cowern on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var objects = JSON(value: nil)
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(objects.array.enumerated()), id: \.offset) { _, object in
                    Text(object["title"].string)
                }
            }
        }
        .task {
            do {
                objects = try JSON(string: json)
            } catch {
                print("There was an error decoding json")
            }
        }
    }
}

#Preview {
    ContentView()
}
