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
                linkedList.printList()
            } label: {
                Text("Push to linked list")
            }
            
            Button {
                linkedList.append(8)
                linkedList.printList()
            } label: {
                Text("Append to linked list")
            }

            Text("\(linkedList.description)")
            
            Text("Count: \(linkedList.count)")
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
