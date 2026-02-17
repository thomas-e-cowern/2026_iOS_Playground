//
//  StateToggleView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/17/26.
//

import SwiftUI

struct StateToggleView: View {
    
    @State private var isOn: Bool = false
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Button {
                isOn.toggle()
            } label: {
                ZStack(alignment: isOn ? .trailing : .leading) {
                    HStack {
                        Text("On").opacity(isOn ? 1 : 0)
                        Text("Off").opacity(isOn ? 0 : 1)
                    }
                    .foregroundStyle(.white)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 45, height: 50)
//
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOn ? .green : .red)
                    .frame(width: 100, height: 60)
            }
            
            
            Spacer()
        }

    }
}

#Preview {
    StateToggleView()
}
