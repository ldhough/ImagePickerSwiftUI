import SwiftUI
import UIKit
import Photos

public struct SimpleSelector: View {
    
    private let imageManager:ImageManager
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 0), count: SimpleSelectorConfig.thumbnailCountPerRow)
    
    public init(_ manager: SimpleSelectorManager) {
        print("Initializing SimpleSelector view!")
        self.imageManager = ImageManager(simpleSelectorManager: manager)
    }
    
    private var selectorView: some View {
        ScrollView {
            LazyVGrid(columns: cols, spacing: 0) {
                ForEach((0 ... self.imageManager.assetFetchResult.count-1), id: \.self) { index in
                    let wrappedImage = self.imageManager.getCreateWrappedImage(forIndex: index)//WrappedImage(imageManager: self.imageManager, loadsIndex: index)
                    ThumbnailView(index: index,
                                  imageManager: self.imageManager,
                                  wrappedImage: wrappedImage)
                        .onAppear() {
                            DispatchQueue.global(qos: .userInteractive).async {
                                self.imageManager.manageLoadingFreeing(forIndex: index)
                            }
                        }.border(Color.black)
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
