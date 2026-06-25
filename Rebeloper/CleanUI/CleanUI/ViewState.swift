//
//  ViewState.swift
//  CleanUI
//
//  Created by Thomas Cowern on 6/25/26.
//

import Foundation

enum ViewState<T> {
    case loading
    case success(T)
    case empty
    case error(String)
}
