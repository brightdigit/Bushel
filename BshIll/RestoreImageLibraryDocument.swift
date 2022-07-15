//
//  BshIllDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers



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
    let decoder = JSONDecoder()
    let library : RestoreImageLibrary
    if let data = configuration.file.fileWrappers?["metadata.json"]?.regularFileContents {
      library = try decoder.decode(RestoreImageLibrary.self, from: data)
    } else {
      library = .init()
    }
    self.init(library: library, sourceFileWrapper: configuration.file)
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let fileWrapper : FileWrapper = .init(directoryWithFileWrappers: [String : FileWrapper]())
    
    let imagesDirectoryFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
    imagesDirectoryFileWrapper.preferredFilename = "Restore Images"
    let existingImageDirectoryFileWrapper = configuration.existingFile?.fileWrappers?["Restore Images"]?.fileWrappers
    let sourceImageDirectoryFileWrapper = self.sourceFileWrapper?.fileWrappers?["Restore Images"]?.fileWrappers
    let imageFileWrappers = try library.items.map { file in
      if let fileWrapper = sourceImageDirectoryFileWrapper?[file.name] {
        return fileWrapper
      }
      if let fileWrapper = existingImageDirectoryFileWrapper?[file.name] {
        return fileWrapper
      }
          
            return try FileWrapper(url: file.metadata.url, options: [.immediate, .withoutMapping])
      
    }
    _ = imageFileWrappers.map(imagesDirectoryFileWrapper.addFileWrapper)
    let encoder = JSONEncoder()
    let data = try encoder.encode(self.library)
    let metdataFileWrapper = FileWrapper(regularFileWithContents: data)
    metdataFileWrapper.preferredFilename = "metadata.json"
    fileWrapper.addFileWrapper(imagesDirectoryFileWrapper)
    fileWrapper.addFileWrapper(metdataFileWrapper)
    return fileWrapper
  }
}
