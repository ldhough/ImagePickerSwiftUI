import SwiftUI
import UIKit
import Photos

public struct SimpleSelector: View {
    
    private let imageManager:ImageManager
    
    public init(_ manager: SimpleSelectorManager) {
        print("Initializing SimpleSelector view!")
        self.imageManager = ImageManager(simpleSelectorManager: manager)
    }
    
    private var selectorView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0),
                                GridItem(.flexible(), spacing: 0),
                                GridItem(.flexible(), spacing: 0)], spacing: 0) {
                ForEach((0 ... self.imageManager.assetFetchResult.count-1), id: \.self) { index in
                    let wiv = self.imageManager.getWrappedImage(forIndex: index)
                    ThumbnailView(index: index,
                                  imageManager: self.imageManager,
                                  wrappedImageView: wiv)//self.imageManager.getWrappedImage(forIndex: index))
                        .onAppear(perform: {
                            print("ON APPEAR TRIGGERED FOR INDEX \(index)")
                            self.imageManager.fetchImageAsync(forIndex: index)
                        }).onDisappear(perform: {
                            //self.imageManager.releaseImage(forIndex: index)
                        })
                }
            }
        }
    }
    
    public var body: some View {
        VStack {
            selectorView
        }
    }
    
}
