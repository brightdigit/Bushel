//
//  RestoreImageDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Virtualization

import struct CryptoKit.SHA256

typealias CryptoSHA256 = CryptoKit.SHA256

enum MissingError : Error {
  case notImplemented
  case needDefinition(Any)
}
enum Formatters {
  static let lastModifiedDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = $0
    return formatter
  }("E, d MMM yyyy HH:mm:ss Z")
}

protocol ImageContainer {
  var metadata : ImageMetadata { get }
  var installer : ImageInstaller { get }
}

struct ImageMetadata : Codable, CustomDebugStringConvertible {
  internal init(isImageSupported: Bool, buildVersion: String, operatingSystemVersion: OperatingSystemVersion, sha256: SHA256, contentLength: Int, lastModified: Date, url: URL) {
    self.isImageSupported = isImageSupported
    self.buildVersion = buildVersion
    self.operatingSystemVersion = operatingSystemVersion
    self.sha256 = sha256
    self.contentLength = contentLength
    self.lastModified = lastModified
    self.url = url
  }
  
  let isImageSupported : Bool
  let buildVersion : String
  let operatingSystemVersion : OperatingSystemVersion
  let sha256 : SHA256
  let contentLength : Int
  let lastModified: Date
  let url : URL
  
  var debugDescription: String {
    "\(Self.self)(isImageSupported: \(self.isImageSupported), buildVersion: \"\(self.isImageSupported)\", operatingSystemVersion: \(self.operatingSystemVersion.debugDescription), sha256: \(self.sha256.debugDescription), contentLength: \(self.contentLength), lastModified: \(self.lastModified.debugDescription), url: \(self.url.debugDescription)"
  }
}



extension VZMacOSRestoreImage {
  var isImageSupported: Bool {
#if swift(>=5.7)
    if #available(macOS 13.0, *) {
      return self.isSupported
    } else {
      return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
    }
#else
    return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
#endif
  }
}

extension ImageMetadata{
  init (sha256: SHA256, contentLength: Int, lastModified: Date, vzRestoreImage: VZMacOSRestoreImage) {
    self.init(isImageSupported: vzRestoreImage.isImageSupported, buildVersion: vzRestoreImage.buildVersion, operatingSystemVersion: vzRestoreImage.operatingSystemVersion, sha256: sha256, contentLength: contentLength, lastModified: lastModified, url: vzRestoreImage.url)
  }
}
struct VirtualizationMacOSRestoreImage : ImageContainer {
  init(sha256: SHA256, contentLength: Int, lastModified: Date, vzRestoreImage: VZMacOSRestoreImage) {
    self.metadata = .init(sha256: sha256, contentLength: contentLength, lastModified: lastModified, vzRestoreImage: vzRestoreImage)
    self.vzRestoreImage = vzRestoreImage
  }
  
  let metadata: ImageMetadata
  
  
  
  
  let vzRestoreImage : VZMacOSRestoreImage
  var installer: ImageInstaller {
    return self.vzRestoreImage
  }
  
  init  (vzRestoreImage : VZMacOSRestoreImage, sha256 : SHA256?) async throws {
    if vzRestoreImage.url.isFileURL {
      let sha256Value : SHA256
      if let sha256Arg = sha256 {
        sha256Value = sha256Arg
      } else {
        sha256Value = try await SHA256(fileURL: vzRestoreImage.url)
      }
      let contentLength : Int = 0
      let lastModified : Date = .init()
      self.init(sha256: sha256Value, contentLength: contentLength, lastModified: lastModified, vzRestoreImage: vzRestoreImage)
    } else {
      let headers = try await vzRestoreImage.headers()
      try self.init(vzRestoreImage: vzRestoreImage, headers: headers)
    }
  }
  init  (vzRestoreImage : VZMacOSRestoreImage, headers : [AnyHashable : Any]) throws {
    guard let contentLengthString = headers["Content-Length"] as? String else {
      throw MissingError.needDefinition((headers,"Content-Lenght"))
    }
    guard let contentLength = Int(contentLengthString) else {
      throw MissingError.needDefinition((headers,"Content-Lenght"))
    }
    guard let lastModified = (headers["Last-Modified"] as? String).flatMap(Formatters.lastModifiedDateFormatter.date(from:)) else {
      
      throw MissingError.needDefinition((headers,"Last-Modified"))
    }
    guard let sha256Hex = headers["x-amz-meta-digest-sha256"] as? String else {
      
      throw MissingError.needDefinition((headers,"x-amz-meta-digest-sha256"))
    }
    guard let sha256 = SHA256(hexidecialString: sha256Hex) else {
      throw MissingError.needDefinition((headers,"x-amz-meta-digest-sha256"))
    }
    
    
    self.init(sha256: sha256, contentLength: contentLength, lastModified: lastModified, vzRestoreImage: vzRestoreImage)
  }
  //headers : [AnyHashable : Any]
}
extension VZMacOSRestoreImage : ImageInstaller {
  
  func headers (withSession session: URLSession = .shared) async throws -> [AnyHashable : Any] {
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    let (_, response) = try await session.data(for: request)
    
    guard let response = response as? HTTPURLResponse else {
      throw MissingError.needDefinition(response)
    }
    
    return response.allHeaderFields
  }
  //    var isImageSupported: Bool {
  //        if #available(macOS 13.0, *) {
  //            return self.isSupported
  //        } else {
  //            return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
  //        }
  //    }
}

protocol ImageInstaller {
  
}


struct MockInstaller : ImageInstaller {
  
}

protocol RestoreImageFactory {
  //func restoreImage(
}

struct RestoreImage : Identifiable, Hashable {
  static func == (lhs: RestoreImage, rhs: RestoreImage) -> Bool {
    lhs.metadata.sha256 == rhs.metadata.sha256
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.metadata.sha256.data)
  }
  
  
  
  var id: Data {
    return metadata.sha256.data
  }
  
  //    let isSupported : Bool
  //    let buildVersion : String
  //    let operatingSystemVersion : OperatingSystemVersion
  //    let sha256 : SHA256
  //      let contentLength : Int
  //    let lastModified: Date
  
  let installer : ImageInstaller
  let metadata : ImageMetadata
  init(metadata : ImageMetadata, installer: ImageInstaller) {
    self.metadata = metadata
    self.installer = installer
  }
  
  init(imageContainer: ImageContainer) {
    self.init(metadata: imageContainer.metadata, installer: imageContainer.installer)
  }
  
}

extension RestoreImage {
  
  enum Location {
    case library
    case local
    case remote
  }
  var location : Location {
    if self.metadata.url.isFileURL {
#warning("fix to allow subfolders under `Restore Images`")
      let directoryURL = metadata.url.deletingLastPathComponent()
      guard directoryURL.lastPathComponent == "Restore Images"  else {
        return .local
      }
      guard directoryURL.deletingLastPathComponent().pathExtension == "bshrilib" else {
        return .local
      }
      return .library
    } else {
      return .remote
    }
  }
}



extension UTType {
  //[.init("com.apple.itunes.ipsw")!, .init("com.apple.iphone.ipsw")!]
  static let iTunesIPSW : UTType = .init("com.apple.itunes.ipsw")!
  static let iPhoneIPSW : UTType = .init("com.apple.iphone.ipsw")!
  
  static let ipswTypes = [iTunesIPSW, iPhoneIPSW]
}



protocol RestoreImageLoader {
  var restoreImageResult : Result<RestoreImage, Error>? { get }
}


struct MockRestoreImageLoader : RestoreImageLoader {
  let restoreImageResult : Result<RestoreImage, Error>?
}

extension Result {
  
  func unwrap<NewSuccessType>(error: Failure) -> Result<NewSuccessType, Failure> where Success == Optional<NewSuccessType> {
    self.flatMap { optValue in
      guard let value = optValue else {
        return .failure(error)
      }
      return .success(value)
    }
  }
  
  @inlinable public func flatMap<NewSuccess>(_ transform: (Success) async throws -> NewSuccess) async -> Result<NewSuccess, Failure> where Failure == Error {
    let oldSuccess : Success
    
    switch self {
    case .failure(let failure):
      return .failure(failure)
    case .success(let success):
      oldSuccess = success
    }

    let result : Result<NewSuccess, Failure>
    do {
      let newSuccess = try await transform(oldSuccess)
      result = .success(newSuccess)
    } catch {
      result = .failure(error)
    }
    
    return result
  }
//  func flatMap<NewSuccessType>() async -> Result<NewSuccessType, Failure> {
//
//  }
}
extension FileManager {
  func createTemporaryFile(for type: UTType) -> URL {
    let tempFile : URL
    //
#if swift(>=5.7)
    if #available(macOS 13.0, *) {
      tempFile = self.temporaryDirectory.appending(path: UUID().uuidString).appendingPathExtension(for: type)
    } else {
      tempFile = self.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(for: type)
    }
#else
    tempFile = self.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(for: type)
#endif
    return tempFile
  }
//  func createTemporaryFileWithData(_ data: Data, extension: String) -> URL {
//    let tempFile = createTemporaryFileWithExtension("")
//#if swift(>=5.7)
//    if #available(macOS 13.0, *) {
//      self.createFile(atPath: tempFile.path(), contents: data)
//    } else {
//      self.createFile(atPath: tempFile.path, contents: data)
//    }
//#else
//    self.createFile(atPath: tempFile.path, contents: data)
//#endif
//    return tempFile
//  }
}


protocol FileAccessor {
  func getData () -> Data?
  func writeTo(_ url: URL) throws
  
}

extension FileWrapper : FileAccessor {
  func getData() -> Data? {
    return self.regularFileContents
  }
  
  func writeTo(_ url: URL) throws {
    try self.write(to: url, originalContentsURL: nil)
  }
}

class FileRestoreImageLoader : RestoreImageLoader {

  var restoreImageResult : Result<RestoreImage, Error>? = nil
  
  
  init(from file: FileAccessor) {
    Task{
      let tempFileURL = FileManager.default.createTemporaryFile(for: .iTunesIPSW)
      let sha256 = await Task {
        try Result{file.getData()}.unwrap(error: NSError()).map(CryptoSHA256.hash).map{Data($0)}.map(SHA256.init(data:)).get()
      }.result
            //let dataResult = Result{ try getData() }.unwrap(error: NSError())
      //let urlResult = dataResult.map(FileManager.default.createTemporaryFileWithData(_:))
      let vzMacOSRestoreImage = await Task {
        try await Result{ try file.writeTo(tempFileURL)}.map{ tempFileURL }.flatMap(VZMacOSRestoreImage.loadFromURL).get()
      }.result
      
      let virtualImageResultArgs : Result<(VZMacOSRestoreImage, SHA256),Error> = vzMacOSRestoreImage.flatMap { image in
        return sha256.map{
          return (image, $0)
        }
      }
      
      let virtualImageResult = await virtualImageResultArgs.flatMap(VirtualizationMacOSRestoreImage.init)
      let restoreImage = virtualImageResult.map(RestoreImage.init(imageContainer:))
      dump(restoreImage)
      DispatchQueue.main.async {
        self.restoreImageResult = restoreImage
      }
//      let restoreImageResult = await urlResult.map { url in
//        await VZMacOSRestoreImage.loadFromURL(url)
//      }
//      DispatchQueue.main.async {
//        self.restoreImageResult = restoreImageResult
//      }
    }
  }
  
  
  
  //         func beginLoad () {
  //
  //            VZMacOSRestoreImage.load(from: sourceFileURL) { result in
  //                self.restoreImageResult = result.map(RestoreImage.init(imageMetadata:))
  //            }
  //        }
}



struct RestoreImageDocument: FileDocument {
  internal init(loader: RestoreImageLoader) {
    self.loader = loader
  }
  
  let loader : RestoreImageLoader
  
  static let readableContentTypes = UTType.ipswTypes
  
  
  init(configuration: ReadConfiguration) throws {
    self.loader = FileRestoreImageLoader(from: configuration.file)
  }
  
  
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    fatalError()
  }
  
}
