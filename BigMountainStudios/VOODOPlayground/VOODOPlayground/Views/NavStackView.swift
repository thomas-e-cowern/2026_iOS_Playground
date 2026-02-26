//
//  NavStackView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/26/26.
//

import SwiftUI

struct NavStackView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Go to Intro View") {
                DevloperIntroView()
            }
            .navigationTitle("Developer")
        }
        .environment(DeveloperOO())
        .font(.title)
    }
}

#Preview {
    NavStackView()
}


@Observable
class DeveloperOO {
    var name: String = "Awesome Developer"
}


struct DeveloperView: View {
    
    @Environment(DeveloperOO.self) private var dev
    
    var body: some View {
        Text("Hello, \(dev.name)!")
            .navigationTitle("Developer View")
    }
}

struct DevloperIntroView: View {
    var body: some View {
        NavigationLink("Go to Developer View") {
            DeveloperView()
        }
    }
}
