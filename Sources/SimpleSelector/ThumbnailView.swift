//
//  File.swift
//  
//
//  Created by Lannie Hough on 5/24/21.
//

import Foundation
import SwiftUI

internal struct ThumbnailView: View {
    
    let imageIndex:Int
    let imageManager:ImageManager
    @ObservedObject var wrappedImageView:WrappedImageView
    
    init(index: Int, imageManager: ImageManager, wrappedImageView: WrappedImageView) {
        self.imageIndex = index
        self.imageManager = imageManager
        self.wrappedImageView = wrappedImageView
    }
    
    private func thumbnailViewSize() -> CGFloat {
        return UIScreen.main.bounds.width / CGFloat(SimpleSelectorConfig.thumbnailCountPerRow)
    }
    
    var body: some View {
        let viewSize = thumbnailViewSize()
        if let image = wrappedImageView.image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: viewSize, height: viewSize, alignment: .center)
                .clipped()
        } else {
            ProgressView().frame(width: viewSize, height: viewSize, alignment: .center)
        }
    }
}
