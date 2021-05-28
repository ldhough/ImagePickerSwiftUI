//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation
import SwiftUI

// Used to account for floating point math errors
internal func fp_eq<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T, tolerance: Float = 0.0001) -> Bool {
    return abs(Float(lhs) - Float(rhs)) <= tolerance
}

internal func fp_gte<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> Bool {
    return round(1000*lhs)/1000 >= rhs
}

internal extension View {
    // Given the size frame enclosing a view, return optimal size of that view
    // Takes modifiers like .fit, .fill into account
    func viewDimensionsInFrame(_ frame: CGSize) -> CGSize {
        let controller = UIHostingController(rootView: self)
        let viewDimensions = controller.view.systemLayoutSizeFitting(frame)
        return viewDimensions
    }
}

internal class ImageLock {
    
    private var lock:pthread_mutex_t = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&lock, nil)
    }
    
    public func tryGetLock() -> Bool {
        let result = pthread_mutex_trylock(&lock)
        return result == 0
    }
    
    public func releaseLock() {
        pthread_mutex_unlock(&lock)
    }
    
    deinit {
        pthread_mutex_destroy(&lock)
    }
    
}
