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
    
    private static let predicates:[SelectorMediaTypes:NSPredicate] = [
        .videos: NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue),
        .images: NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
    ]
    
    private let manager = PHImageManager.default()
    private let ssm:SimpleSelectorManager
    private let mediaFetchOptions:PHFetchOptions
    private let thumbnailReqOptions:PHImageRequestOptions

    private var selectorLoadedImages:[Int:WrappedImage] = [:]
    private var currentlyLoadedImages:Set<Int> = []
    
    public func getCreateWrappedImage(forIndex: Int) -> WrappedImage {
        if selectorLoadedImages[forIndex] == nil {
            selectorLoadedImages[forIndex] = WrappedImage(imageManager: self, loadsIndex: forIndex)
        }
        return selectorLoadedImages[forIndex]!
    }
    
    
    var assetFetchResult:PHFetchResult<PHAsset>
    private let load_lock:ImageLock
    private let load_range_lock:ImageLock
    private var loadRange:ClosedRange<Int>?
    
    init(simpleSelectorManager: SimpleSelectorManager) {
        self.load_lock = ImageLock()
        self.load_range_lock = ImageLock()
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
    
    private static func getFetchResult(withFetchOptions: PHFetchOptions) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: withFetchOptions)
    }
    
    /*
     When an image is to be loaded it will be added to this set
     Necessary because even though manageImageLoading is atomically locked,
     it makes async load calls - a second call to manageImageLoading should
     not attempt to load images that are still in the process of being
     loaded
    */
    private var beingLoadedSet:Set<Int> = []
    
    func manageLoadingFreeing(forIndex: Int) {
        
        // Reduce the amount of work that needs to be done
        
        if forIndex % 10 != 0 {
            return
        }
        
        /*
         Calculate a range of images to attempt to keep loaded around the index of
         the view that called this function when it appeared
         */
        
        self.load_range_lock.getLock() // blocks
        
        let rangeVal = 20 // Mostly arbitrary
        let proposedStartRange = forIndex - rangeVal
        let startRange = proposedStartRange < 0 ? 0 : proposedStartRange
        let proposedEndRange = forIndex + rangeVal
        let maxPhotoIndex = self.assetFetchResult.count-1
        let endRange = proposedEndRange > maxPhotoIndex ? maxPhotoIndex : proposedEndRange
        self.loadRange = startRange ... endRange
        
        self.load_range_lock.releaseLock()
        
        self.manageImageLoading()
        self.manageImageFreeing()
        
    }
        
    // Atomically locked so that it may not execute the same code in parallel
    private func manageImageLoading() {

        if !load_lock.tryGetLock() {
            //print("Did not obtain lock for index \(forIndex)")
            return
        }
        
        if let lr = self.loadRange {
            for i in lr {
                self.fetchImageAsync(forIndex: i, callback: { image in
                    //self.beingLoadedSet.remove(i)
                    guard let _ = image else {
                        return
                    }
                    self.load_range_lock.getLock()
                    self.getCreateWrappedImage(forIndex: i).image = image
                    self.currentlyLoadedImages.insert(i)
                    self.load_range_lock.releaseLock()
                })
            }
        }

        load_lock.releaseLock()
    }
    
    private func manageImageFreeing() {
        self.load_range_lock.getLock()
        if let lr = loadRange {
            for index in self.currentlyLoadedImages {
                if !lr.contains(index) {
                    print("FREEING IMAGE AT INDEX: \(index)")
                    self.releaseImage(forIndex: index)
                    //self.selectorLoadedImages[index] = nil
                    self.currentlyLoadedImages.remove(index)
                }
            }
            print("\(self.currentlyLoadedImages.count) ARE LOADED")
        }
        self.load_range_lock.releaseLock()
    }
    
    // Function fetches images for thumbnails in the selector view
    private func fetchImageAsync(forIndex: Int, callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            manager.requestImage(for: self.assetFetchResult.object(at: forIndex),
                                 targetSize: SimpleSelectorConfig.thumbnailTargetSize,
                                 contentMode: .aspectFill, options: thumbnailReqOptions) { image, error  in
                if let _ = error {}
                guard let image = image else {
                    // Image can't be loaded for this index for whatever reason
                    callback(nil)
                    return
                }
                DispatchQueue.main.async { // Update UI on main thread
                    // Create a UIImage to be displayed in a thumbnail as an Image view
                    callback(image)
                }
            }
        }
    }
    
    // Used to free images that are out of sight to conserve memory
    private func releaseImage(forIndex: Int) {
        DispatchQueue.main.async {
            self.selectorLoadedImages[forIndex]?.image = nil
        }
    }
}

internal class WrappedImage: ObservableObject {
    let imageManager:ImageManager
    @Published var image:UIImage?
    let index:Int
    
    init(imageManager: ImageManager, loadsIndex: Int) {
        self.imageManager = imageManager
        self.index = loadsIndex
    }
}

