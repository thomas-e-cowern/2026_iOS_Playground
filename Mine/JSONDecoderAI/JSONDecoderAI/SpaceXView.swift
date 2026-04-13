//
//  SpaceXView.swift
//  JSONDecoderAI
//
//  Created by Thomas Cowern on 3/26/26.
//

import SwiftUI

struct SpaceXView: View {
    
    @State private var json: JSONValue = .null
    
    var body: some View {
        NavigationStack {
            List {
                let thrusters = json.arrayValue ?? []
                
                ForEach(Array(thrusters.enumerated()), id: \.offset) { _, product in
                    LabeledContent("NAME", value: "\(product["name"].stringValue ?? "No name")")
                }
            }
            .task {
                if let url = Bundle.main.url(forResource: "spacex", withExtension: "json"),
                   let data = try? Data(contentsOf: url) {
                    json = JSONValue.decode(from: data)
                    print(json)
                }
            }
        }
    }
    
}

#Preview {
    SpaceXView()
}
