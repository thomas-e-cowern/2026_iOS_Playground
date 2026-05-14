//
//  LoadingButton.swift
//  CustomLoadingButton
//
//  Created by Thomas Cowern on 4/27/26.
//

import SwiftUI

struct LoadingButton: View {
    
    let title: String
    @Binding var state: LoadingButtonState
    let action: () -> ()
    
    var body: some View {
        Color.clear
            .modifier(LoadingButtonModifier(title: title, state: $state, action: action))
    }
}

#Preview {
    LoadingButton(title: "This is the title", state: .constant(.idle), action: {})
}
