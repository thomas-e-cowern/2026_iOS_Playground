//
//  CardView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/13/26.
//

import SwiftUI

struct CardView<Content: View>: View {
    
    let title: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GroupBox {
            Text(title)
                .font(.title.bold().width(.compressed))
            Divider()
            
            VStack(content: content)
        }
        .padding()
    }
}

#Preview {
    CardView(title: "Preview Title") {
        Text("Here is some content")
        Text("Here is some more content")
    }
}
