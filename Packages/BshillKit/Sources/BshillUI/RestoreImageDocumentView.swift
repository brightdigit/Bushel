//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import BshillMachine

struct MockImageContainer : ImageContainer {
  let metadata: BshillMachine.ImageMetadata
  
  func installer() async throws -> BshillMachine.ImageInstaller {
    return MockInstaller()
  }
  
  
}
struct MockImageManager : ImageManager {
  let metadata: BshillMachine.ImageMetadata
  func loadFromAccessor(_ accessor: BshillMachine.FileAccessor) async throws -> Void {
    return
  }
  
  func imageContainer(vzRestoreImage: Void, sha256: BshillMachine.SHA256?) async throws -> BshillMachine.ImageContainer {
    return MockImageContainer(metadata: metadata)
  }
  
  typealias ImageType = Void
  
  
}

struct RestoreImageDocumentView<ImageManagerType : ImageManager>: View {
  let manager : ImageManagerType
  
  internal init(url: URL?, manager: ImageManagerType, _ fetchImage : @escaping () async throws -> RestoreImage) {
    self.url = url
    self.fetchImage = fetchImage
    self.manager = manager
  }
  
  internal init(document: RestoreImageDocument, manager: ImageManagerType, url: URL? = nil, loader: RestoreImageLoader = FileRestoreImageLoader()) {
    let accessor = FileWrapperAccessor(fileWrapper: document.fileWrapper, url: url, sha256: nil)
    self.init(url: url, manager: manager) {
      try await loader.load(from: accessor, using: manager)
    }
  }
  
//   let document: RestoreImageDocument
//  let loader : RestoreImageLoader
  let fetchImage : () async throws -> RestoreImage
  let url : URL?
  @State var restoreImageResult : Result<RestoreImage, Error>?
  
  var body: some View {
    Group{
      switch self.restoreImageResult {
      case .none:
        ProgressView()
      case .success(let image):
        RestoreImageView(image: image).fixedSize()
      default:
        EmptyView()
      }
    }
    .onAppear{
      Task {
        let restoreImageResult : Result<RestoreImage, Error>
        do {
          let image = try await self.fetchImage()
          restoreImageResult = .success(image)
        } catch {
          restoreImageResult = .failure(error)
        }
        DispatchQueue.main.async {
          self.restoreImageResult = restoreImageResult
        }
      }
       
    }
    }
}

struct RestoreImageDocumentView_Previews: PreviewProvider {
    static var previews: some View {
      
      RestoreImageDocumentView(url: nil, manager: MockImageManager(metadata: .Previews.venturaBeta3)) {
        return .Previews.usingMetadata(.Previews.venturaBeta3)
      }
//        RestoreImageDocumentView(document: RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil)))
//
//      RestoreImageDocumentView(document: .Previews.previewLoadedDocument)
      //EmptyView()
    }
}


