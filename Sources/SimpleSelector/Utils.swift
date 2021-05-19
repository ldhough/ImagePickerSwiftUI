//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation

// Used to account for floating point math errors
private func fp_eq<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T, tolerance: Float = 0.0001) -> Bool {
    return abs(Float(lhs) - Float(rhs)) <= tolerance
}

private func fp_gte<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> Bool {
    return round(1000*lhs)/1000 >= rhs
}
