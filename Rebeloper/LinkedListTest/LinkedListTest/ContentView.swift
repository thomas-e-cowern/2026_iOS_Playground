//
//  ContentView.swift
//  LinkedListTest
//
//  Created by Thomas Cowern on 6/9/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var linkedList = LinkedList<Int>()
    @State var input: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            
            TextField("Enter a number", value: $input, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button {
                linkedList.push(input)
                linkedList.printList()
            } label: {
                Text("Push to linked list")
            }
            
            Button {
                linkedList.append(input)
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
