//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/19/21.
//

import Foundation
import Photos
import SwiftUI

internal class ImageManager {
    
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
    var selectorLoadedImages:[Int:WrappedImageView] = [:]
    var assetFetchResult:PHFetchResult<PHAsset>
    
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
        self.assetFetchResult = ImageManager.getFetchResult(withFetchOptions: self.mediaFetchOptions)
    }
    
    //make atomic?
    func getWrappedImage(forIndex: Int) -> WrappedImageView {
        if let wiv = selectorLoadedImages[forIndex] {
            return wiv
        } else {
            let wiv = WrappedImageView()
            selectorLoadedImages[forIndex] = wiv
            return wiv
        }
    }
    
    private static func getFetchResult(withFetchOptions: PHFetchOptions) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: withFetchOptions)
    }
    
    func manageImageLoading(forIndex: Int) {
        
    }
    
    // Function fetches images for thumbnails in the selector view
    func fetchImageAsync(forIndex: Int) {
        print("Calling fetchImageAsync!")
        if let _ = self.selectorLoadedImages[forIndex]?.image {
            // If image already loaded, return early
            print("RIP")
            return
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                manager.requestImage(for: self.assetFetchResult.object(at: forIndex),
                                     targetSize: SimpleSelectorConfig.thumbnailTargetSize,
                                     contentMode: .aspectFill, options: thumbnailReqOptions) { image, error  in
                    if let _ = error {
                        print(error)
                        print("RIP 2")
                        // Image can't be loaded for this index for whatever reason
                        //return
                    }
                    guard let image = image else {
                        print("RIP 3")
                        // Image can't be loaded for this index for whatever reason
                        return
                    }
                    DispatchQueue.main.async { // Update UI on main thread
                        // Create an image view to be displayed in a thumbnail
                        selectorLoadedImages[forIndex]?.image = Image(uiImage: image)
                        print("SETTING LOADED THUMBNAIL IMAGE!")
                    }
                }
            }
        }
    }
    
    // Used to free images that are out of sight to conserve memory
    func releaseImage(forIndex: Int) {
        if let _ = self.selectorLoadedImages[forIndex] {
            self.selectorLoadedImages[forIndex]!.image = nil
        }
    }
    
    // Possibly move fetchImageAsync and releaseImage into a single function controlled by a mutex lock
}

internal class WrappedImageView: ObservableObject {
    @Published var image:Image?
}

