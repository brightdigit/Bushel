//
//  BshIllDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers


extension UTType {
  static var restoreImageLibrary: UTType {
    UTType(exportedAs: "com.brightdigit.bshill-rilib")
  }
}


struct RestoreImageLibraryDocument: FileDocument {
  
  let sourceFileWrapper: FileWrapper?
  var library: RestoreImageLibrary
  
  
  init(library : RestoreImageLibrary = .init(), sourceFileWrapper: FileWrapper? = nil) {
    self.library = library
    self.sourceFileWrapper = sourceFileWrapper
    
  }
  
  mutating func beginReload () async {
    let loader = FileRestoreImageLoader()
    guard let fileWrapper = sourceFileWrapper else {
      return
    }
    guard fileWrapper.isDirectory else {
      return
    }
    guard let childWrappers = fileWrapper.fileWrappers else {
      return
    }
    guard let imageDirectoryWrapper = childWrappers["Restore Images"] else {
      return
    }
    guard let imageWrappers = imageDirectoryWrapper.fileWrappers, imageDirectoryWrapper.isDirectory else {
      return
    }
    let restoreImages = await withTaskGroup(of: RestoreImage?.self) { group in
      for (_, imageWrapper) in imageWrappers {
        group.addTask {
          try? await loader.load(from: imageWrapper)
        }
      }
        return await group.reduce(into: [RestoreImage?]()) { images, image in
          images.append(image)
        }
      
    }.compactMap{$0}.map(RestoreImageLibraryItemFile.init(restoreImage:))
    self.library = .init(items: restoreImages)
  }
  
  
  static let readableContentTypes: [UTType] = [.restoreImageLibrary]
  
  init(configuration: ReadConfiguration) throws {
    self.init(sourceFileWrapper: configuration.file)
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    
    return .init(directoryWithFileWrappers: [String : FileWrapper]())
  }
}
