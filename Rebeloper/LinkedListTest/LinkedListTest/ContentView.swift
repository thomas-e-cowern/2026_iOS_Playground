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
    @State var index: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            
            VStack(spacing: 0) {
                Text("Enter a number")
                TextField("Enter a number", value: $input, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            
            VStack(spacing: 0) {
                Text("Enter the index")
                TextField("Enter an index", value: $index, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            
            Button {
                linkedList.insert(input, at: index)
                linkedList.printList()
            } label: {
                Text("Insert value")
            }
            
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
            
            Button {
                linkedList.pop()
                linkedList.printList()
            } label: {
                Text("Pop from linked list")
            }

            Button {
                linkedList.removeLast()
                linkedList.printList()
            } label: {
                Text("Remove last from linked list")
            }
            
            Button {
                linkedList.remove(at: index)
                linkedList.printList()
            } label: {
                Text("Remove at index \(index)")
            }

            
            Button {
                linkedList.removeAll()
                linkedList.printList()
                index = 0
                input = 0
            } label: {
                Text("Remove all nodes from linked list")
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
