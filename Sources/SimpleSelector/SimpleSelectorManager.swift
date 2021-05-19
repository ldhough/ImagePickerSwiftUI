//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation
import Photos
import UIKit

public protocol SimpleSelectorManager {
    
    // Determines what actions are taken when an image is selected
    func select()
    // Determines what actions are taken when an image is deselected
    func deselect()
    // When executed, applies changes to currently selected UIImage
    func applyToSelected(image: UIImage)
    
    // Determines the resolution for the displayed selected image
    var selectedFieldResolution:PHVideoRequestOptionsDeliveryMode { get set }
    // Determines the resolution for thumbnail images that can be selected
    var selectorFieldResolution:PHVideoRequestOptionsDeliveryMode { get set }
    // Determines the resolution of image objects returned for use
    var fetchResolution:PHVideoRequestOptionsDeliveryMode { get set }
    
    // Determines which of multiple selected photos is displayed prominently
    var focusBehavior:SelectorFocusBehavior { get set }
    
}

public enum SelectorFocusBehavior {
    case focusRecentSelected
    case focusFirstSelected
}
