   //
//  MainView.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

// View
import SwiftUI

struct MainViewView: View {
    @State private var oo = MainViewOO()
    
    var body: some View {
        List(oo.data) { datum in
            Text(datum.name)
        }
        .task {
            oo.fetch()
        }
    }
}

#Preview {
    MainViewView()
}

// Observable Object
import Observation
import SwiftUI

@Observable
class MainViewOO {
    var data: [MainViewDO] = []
    
    func fetch() {
        data = [MainViewDO(name: "Datum 1"),
                MainViewDO(name: "Datum 2"),
                MainViewDO(name: "Datum 3")]
    }
}

// Data Object
import Foundation

struct MainViewDO: Identifiable {
    let id = UUID()
    var name: String
}
