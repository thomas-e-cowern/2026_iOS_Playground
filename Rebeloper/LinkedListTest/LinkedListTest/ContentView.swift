//
//  ContentView.swift
//  LinkedListTest
//
//  Created by Thomas Cowern on 6/9/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var linkedList = LinkedList<Int>()
    
    var body: some View {
        VStack(spacing: 24) {
            Button {
                linkedList.push(1)
            } label: {
                Text("Add to linked list")
            }

            Text("\(linkedList.description)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
