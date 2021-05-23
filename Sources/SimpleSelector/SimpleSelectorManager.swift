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
    
    //MOVE THESE TO SOME KIND OF CONFIG CLASS
    // Determines the resolution for the displayed selected image
    var selectedFieldResolution:PHImageRequestOptionsDeliveryMode { get set }
    // Determines the resolution for thumbnail images that can be selected
    var selectorFieldResolution:PHImageRequestOptionsDeliveryMode { get set }
    // Determines the resolution of image objects returned for use
    var fetchResolution:PHImageRequestOptionsDeliveryMode { get set }
    
    var focusBehavior:SelectorFocusBehavior { get set }
    var mediaTypes:[SelectorMediaTypes] { get set }
    
}

public enum SelectorFocusBehavior {
    case focusRecentSelected
    case focusFirstSelected
}

public enum SelectorMediaTypes {
    case images
    case videos
}
