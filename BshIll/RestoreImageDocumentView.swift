//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI



struct RestoreImageDocumentView: View {
  internal init(_ fetchImage : @escaping () async throws -> RestoreImage) {
    self.fetchImage = fetchImage
  }
  internal init(document: RestoreImageDocument, loader: RestoreImageLoader = FileRestoreImageLoader()) {
    self.init {
      try await loader.load(from: document.fileWrapper)
    }
  }
  
//   let document: RestoreImageDocument
//  let loader : RestoreImageLoader
  let fetchImage : () async throws -> RestoreImage
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
      RestoreImageDocumentView {
        return .Previews.usingMetadata(.Previews.venturaBeta3)
      }
//        RestoreImageDocumentView(document: RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil)))
//
//      RestoreImageDocumentView(document: .Previews.previewLoadedDocument)
      //EmptyView()
    }
}


