//
//  ContentView.swift
//  CleanUI
//
//  Created by Thomas Cowern on 6/25/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var state: ViewState<[String]> = .loading
    
    var body: some View {
//        Group {
//            switch state {
//            case .loading:
//                ProgressView("Loading...")
//            case .empty:
//                Text("No data")
//            case .error(let string):
//                Text(string)
//                Button {
//                    Task {
//                        await loadData()
//                    }
//                } label: {
//                    Text("Retry")
//                }
//            case .success(let data):
//                List(data, id: \.self) {
//                    Text($0)
//                }
//            }
//        }
//        .task {
//            await loadData()
//        }
        
        StateView(state: state) { items in
            List(items, id: \.self) {
                Text($0)
            }
        } retry: {
            Task {
                await loadData()
            }
        }
        .task {
            await loadData()
        }

    }
    
    func loadData() async {
        state = .loading
        
        do {
            try await Task.sleep(for: .seconds(2))
            
            let data = ["Hello", "World", "This", "Is", "A", "Test"]
            
            if data.isEmpty {
                state = .empty
            } else {
                state = .success(data)
            }
        } catch  {
            print("There was an eror: \(error.localizedDescription)")
            state = .error("Something went wrong")
        }
    }
}

#Preview {
    ContentView()
}
