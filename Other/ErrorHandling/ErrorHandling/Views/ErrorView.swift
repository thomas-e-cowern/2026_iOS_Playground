//
//  ErrorView.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/28/26.
//

import SwiftUI

struct ErrorView: View {
    let errorTitle: String
    @Environment(ComboController.self) private var controller
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.red)
            .overlay {
                
                VStack {
                    Text(errorTitle)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Button("Reload Users") {
                        Task {
                            print("Relaoding users")
                            controller.clearError()
                            try await controller.getAllCapsules(withError: false)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            }
    }
}
#Preview {
    ErrorView(errorTitle: "There was an error...")
        .environment(ComboController(apiService: APIService()))
}
