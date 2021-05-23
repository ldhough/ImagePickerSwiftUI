//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation
import Photos

private class ImageManager {
    
    // Keep a list of image VIEWS that respond to a small manager class they're initialized with,
    // then set or null a published image to update the view which is rendered
    
    static let predicates:[SelectorMediaTypes:NSPredicate] = [
        .videos: NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue),
        .images: NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
    ]
    
    let manager = PHImageManager.default()
    let ssm:SimpleSelectorManager
    let mediaFetchOptions:PHFetchOptions
    let thumbnailReqOptions:PHImageRequestOptions
    
    init(simpleSelectorManager: SimpleSelectorManager) {
        self.ssm = simpleSelectorManager
        var predicates:[NSPredicate] = []
        for mediaType in ssm.mediaTypes {
            predicates.append(ImageManager.predicates[mediaType] ?? NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue))
        }
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        let phfo = PHFetchOptions()
        let creationSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: SimpleSelectorConfig.ascendingSort)
        phfo.sortDescriptors = [creationSortDescriptor]
        phfo.predicate = compoundPredicate
        self.mediaFetchOptions = phfo
        let reqOptThumbnail = PHImageRequestOptions()
        reqOptThumbnail.isSynchronous = SimpleSelectorConfig.imageFetchIsSync
        reqOptThumbnail.deliveryMode = ssm.selectorFieldResolution
        self.thumbnailReqOptions = reqOptThumbnail
    }
    
    func getFetchResult() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: mediaFetchOptions)
    }
    
    func fetchImage(forIndex: Int) {
        
    }
    
    func releaseImage(forIndex: Int) {
        
    }
}
