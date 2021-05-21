//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation
import SwiftUI

// Used to account for floating point math errors
private func fp_eq<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T, tolerance: Float = 0.0001) -> Bool {
    return abs(Float(lhs) - Float(rhs)) <= tolerance
}

private func fp_gte<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> Bool {
    return round(1000*lhs)/1000 >= rhs
}

private extension View {
    // Given the size frame enclosing a view, return optimal size of that view
    // Takes modifiers like .fit, .fill into account
    func viewDimensionsInFrame(_ frame: CGSize) -> CGSize {
        let controller = UIHostingController(rootView: self)
        let viewDimensions = controller.view.systemLayoutSizeFitting(frame)
        return viewDimensions
    }
}
