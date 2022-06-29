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
struct VirtualizationMacOSRestoreImage : ImageMetadata {
   init(sha256: SHA256, contentLength: Int, lastModified: Date, vzRestoreImage: VZMacOSRestoreImage) {
    self.sha256 = sha256
    self.contentLength = contentLength
    self.lastModified = lastModified
    self.vzRestoreImage = vzRestoreImage
  }
  
  var isImageSupported: Bool {
            if #available(macOS 13.0, *) {
              return self.vzRestoreImage.isSupported
            } else {
              return self.vzRestoreImage.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
            }
  }
  
  var buildVersion: String {
    return self.vzRestoreImage.buildVersion
  }
  
  var operatingSystemVersion: OperatingSystemVersion {
    return self.vzRestoreImage.operatingSystemVersion
  }
  
  let sha256: SHA256
  
  let contentLength: Int
  
  let lastModified: Date
  
  
  let vzRestoreImage : VZMacOSRestoreImage
  var installer: ImageInstaller {
    return self.vzRestoreImage
  }
  
  var url : URL {
    return self.vzRestoreImage.url
  }
  
  
  init  (vzRestoreImage : VZMacOSRestoreImage) async throws {
    let headers = try await vzRestoreImage.headers()
    try self.init(vzRestoreImage: vzRestoreImage, headers: headers)
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

protocol ImageMetadata  {
    var isImageSupported : Bool { get }
        var buildVersion : String { get }
            var operatingSystemVersion : OperatingSystemVersion { get }
  var sha256 : SHA256 { get }
    var contentLength : Int { get }
      var lastModified: Date { get }
  var url : URL { get }
  
  var installer : ImageInstaller { get }
}

struct MockInstaller : ImageInstaller {
    
}

protocol RestoreImageFactory {
    //func restoreImage(
}

struct RestoreImage : Identifiable, Hashable {
    static func == (lhs: RestoreImage, rhs: RestoreImage) -> Bool {
        lhs.sha256 == rhs.sha256
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.sha256.data)
    }
    
  internal init(url : URL, isSupported: Bool, buildVersion: String, operatingSystemVersion: OperatingSystemVersion, sha256: SHA256, contentLength: Int, lastModified: Date, installer: ImageInstaller) {
        self.isSupported = isSupported
        self.buildVersion = buildVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.sha256 = sha256
        self.contentLength = contentLength
        self.lastModified = lastModified
        self.installer = installer
    self.url = url
    }
    
    var id: Data {
        return sha256.data
    }
    
    let isSupported : Bool
    let buildVersion : String
    let operatingSystemVersion : OperatingSystemVersion
    let sha256 : SHA256
      let contentLength : Int
    let lastModified: Date
    
    let installer : ImageInstaller
  let url : URL
   init(imageMetadata : ImageMetadata) {
     self.init(url: imageMetadata.url, isSupported: imageMetadata.isImageSupported, buildVersion: imageMetadata.buildVersion, operatingSystemVersion: imageMetadata.operatingSystemVersion, sha256: imageMetadata.sha256, contentLength: imageMetadata.contentLength, lastModified:imageMetadata.lastModified, installer: imageMetadata.installer)

       
   }
}

extension RestoreImage {
  
  enum Location {
    case library
    case local
    case remote
  }
  var location : Location {
    if self.url.isFileURL {
      let directoryURL = url.deletingLastPathComponent()
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
class FileRestoreImageLoader : RestoreImageLoader {
    let sourceFileURL : URL
    var restoreImageResult : Result<RestoreImage, Error>? = nil
    
    init(data: Data?) throws {
        guard let data = data else {
            throw NSError()
        }
        let tempFile : URL
        //
        if #available(macOS 13.0, *) {
            tempFile = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        } else {
            tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        }
        if #available(macOS 13.0, *) {
            FileManager.default.createFile(atPath: tempFile.path(), contents: data)
        } else {
            FileManager.default.createFile(atPath: tempFile.path, contents: data)
        }
        self.sourceFileURL = tempFile
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
        self.loader = try FileRestoreImageLoader(data: configuration.file.regularFileContents)
    }
    

    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        fatalError()
    }
    
}
