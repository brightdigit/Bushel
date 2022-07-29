import Foundation

public protocol AnyImageManager {
//  func loadFromAccessor(_ accessor: FileAccessor) async throws -> ImageType
//  func imageContainer(vzRestoreImage : ImageType, sha256 : SHA256?) async throws -> ImageContainer
  func load(from accessor: FileAccessor, using loader: RestoreImageLoader) async throws -> RestoreImage
}

extension AnyImageManager {
  
}

extension ImageManager {
  public func load(from accessor: FileAccessor, using loader: RestoreImageLoader) async throws -> RestoreImage {
    try await loader.load(from: accessor, using: self)
  }
}
public protocol ImageManager : AnyImageManager {
  associatedtype ImageType
  func loadFromAccessor(_ accessor: FileAccessor) async throws -> ImageType
  func imageContainer(vzRestoreImage : ImageType, sha256 : SHA256?) async throws -> ImageContainer
}


#warning("Remove `import Virtualization`")
public class FileRestoreImageLoader : RestoreImageLoader {
  public func load<ImageManagerType>(from file: FileAccessor, using manager: ImageManagerType) async throws -> RestoreImage where ImageManagerType : ImageManager {
    try await Task{
      let sha256 : Result<SHA256,Error>
      if let filesha256 = file.sha256 {
        sha256 = .success( filesha256)
      } else {
        async let asha256 = await Task {
          try Result{file.getData()}.unwrap(error: NSError()).map(CryptoSHA256.hash).map{Data($0)}.map(SHA256.init(digest:)).get()
        }.result
        sha256 = await asha256
      }
      async let vzMacOSRestoreImage =  Result{  try await manager.loadFromAccessor(file) }
      
      let virtualImageResultArgs : Result<(ImageManagerType.ImageType, SHA256),Error> = await vzMacOSRestoreImage.tupleWith(sha256)

      let virtualImageResult = await virtualImageResultArgs.flatMap(manager.imageContainer)
      return try virtualImageResult.map(RestoreImage.init(imageContainer:)).get()
    }.value
  }
  
  public init () {}
//
//  var restoreImageResult : Result<RestoreImage, Error>? = nil
//
//
//  init(from file: FileAccessor) {
//    Task{
//      let tempFileURL = FileManager.default.createTemporaryFile(for: .iTunesIPSW)
//      let sha256 = await Task {
//        try Result{file.getData()}.unwrap(error: NSError()).map(CryptoSHA256.hash).map{Data($0)}.map(SHA256.init(data:)).get()
//      }.result
//            //let dataResult = Result{ try getData() }.unwrap(error: NSError())
//      //let urlResult = dataResult.map(FileManager.default.createTemporaryFileWithData(_:))
//      let vzMacOSRestoreImage = await Task {
//        try await Result{ try file.writeTo(tempFileURL)}.map{ tempFileURL }.flatMap(VZMacOSRestoreImage.loadFromURL).get()
//      }.result
//
//      let virtualImageResultArgs : Result<(VZMacOSRestoreImage, SHA256),Error> = vzMacOSRestoreImage.flatMap { image in
//        return sha256.map{
//          return (image, $0)
//        }
//      }
//
//      let virtualImageResult = await virtualImageResultArgs.flatMap(VirtualizationMacOSRestoreImage.init)
//      let restoreImage = virtualImageResult.map(RestoreImage.init(imageContainer:))
//      dump(restoreImage)
//      DispatchQueue.main.async {
//        self.restoreImageResult = restoreImage
//      }
////      let restoreImageResult = await urlResult.map { url in
////        await VZMacOSRestoreImage.loadFromURL(url)
////      }
////      DispatchQueue.main.async {
////        self.restoreImageResult = restoreImageResult
////      }
//    }
//  }
  
  
  
  //         func beginLoad () {
  //
  //            VZMacOSRestoreImage.load(from: sourceFileURL) { result in
  //                self.restoreImageResult = result.map(RestoreImage.init(imageMetadata:))
  //            }
  //        }
}
