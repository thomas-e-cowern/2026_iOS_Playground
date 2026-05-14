//
//  ContentView.swift
//  ResultApp
//
//  Created by Thomas Cowern on 5/14/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var pvm = ProfileViewModel()
    
    var body: some View {
        Group {
            if pvm.errorMessage.isEmpty {
                if pvm.profiles.isEmpty {
                    VStack {
                        Text("Loading Profiles...")
                        ProgressView()
                    }
                } else {
                    List(pvm.profiles) { profile in
                        Text(profile.name)
                    }
                }
            } else {
                Text("There was an error: \(pvm.errorMessage)")
            }
        }
        .onAppear {
            pvm.fetchProfiles()
        }
    }
}

#Preview {
    ContentView()
}
