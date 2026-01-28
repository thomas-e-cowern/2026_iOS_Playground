//
//  CapsuleView.swift
//  ErrorHandling
//
//  Created by Thomas Cowern on 1/27/26.
//

import SwiftUI

struct CapsuleView: View {
    
    let capsule: Capsule
    
    var body: some View {
        VStack {
            Text(capsule.id)
        }
    }
}

#Preview {
//    CapsuleView(capsule: Capsule(reuseCount: 0, waterLandings: 1, landLandings: 0, lastUpdate: "Hanging in atrium at SpaceX HQ in Hawthorne", launches: ["5eb87cdeffd86e000604b330"], serial: "C101", status: "retired", type: "Dragon 1.0", id: "5e9e2c5bf35918ed873b2664"))
    CapsuleView(capsule: Capsule(id: "1234567890"))
}
