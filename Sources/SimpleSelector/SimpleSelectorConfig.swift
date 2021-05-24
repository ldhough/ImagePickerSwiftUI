//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/22/21.
//

import Foundation
import Photos

// Contains some configuration options for the SimpleSelector module
public class SimpleSelectorConfig {
    // Convenience function and property for checking if the user has authorized photo access inside the application
    static var photoAccessAuthorized = true
    static func requestAuth() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                SimpleSelectorConfig.photoAccessAuthorized = true
            }
        }
    }
    
    // Determines order oldest->newest or newest->oldest that photos appear in the selector view
    static var ascendingSort = false
    // Unused currently
    static var imageFetchIsSync = false
    // Determines how many thumbnail images show up on each row in the selector view (2-5) limit
    static var thumbnailCountPerRow = 3 {
        didSet {
            SimpleSelectorConfig.thumbnailCountPerRow = {
                let newValue = SimpleSelectorConfig.thumbnailCountPerRow
                return newValue < 3 ? 3 : newValue > 5 ? 5 : newValue
            }()
        }
    }
    
    // Determines quality of images retrieved for thumbnails
    static var thumbnailTargetSize = CGSize(width: 250, height: 250)
}
