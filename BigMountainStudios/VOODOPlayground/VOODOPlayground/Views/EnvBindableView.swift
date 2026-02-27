//
//  EnvBindableView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/27/26.
//

import SwiftUI

struct EnvBindableView: View {
    
    @Environment(AddressOO.self) private var addressOO
    
    var body: some View {
        Form {
            @Bindable var addressBindable = addressOO
            
            Section("One Way Binding") {
                Text("State: \(addressOO.address.state)")
                    .bold()
            }
            
            Section("Two Way Binding") {
                TextField("Enter State", text: $addressBindable.address.state)
            }
        }
        .headerProminence(.increased)
    }
}

#Preview {
    EnvBindableView()
        .environment(AddressOO())
}
