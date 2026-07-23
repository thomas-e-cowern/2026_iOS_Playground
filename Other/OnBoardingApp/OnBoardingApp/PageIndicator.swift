//
//  PageIndicator.swift
//  OnBoardingApp
//
//  Created by Thomas Cowern on 7/23/26.
//

import SwiftUI

struct PageIndicator: View {
    @Binding var currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                RoundedRectangle(cornerRadius: 4)
                    .fill(currentPage == page ? .white : .white.opacity(0.3))
                    .frame(width: currentPage == page ? 30 : 15, height: 6)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
            }
        }
    }
}
