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

extension VZMacOSRestoreImage : ImageMetadata {
    var isImageSupported: Bool {
        if #available(macOS 13.0, *) {
            return self.isSupported
        } else {
            return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
        }
    }
}

protocol ImageInstaller {
    
}

protocol ImageMetadata : ImageInstaller {
    var isImageSupported : Bool { get }
        var buildVersion : String { get }
            var operatingSystemVersion : OperatingSystemVersion { get }
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
    
    internal init(isSupported: Bool, buildVersion: String, operatingSystemVersion: OperatingSystemVersion, sha256: SHA256, contentLength: Int, lastModified: Date, installer: ImageInstaller) {
        self.isSupported = isSupported
        self.buildVersion = buildVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.sha256 = sha256
        self.contentLength = contentLength
        self.lastModified = lastModified
        self.installer = installer
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
//    init(isSupported: Bool, buildVersion: String, operatingSystemVersion: OperatingSystemVersion, installer: ImageInstaller) {
//       self.isSupported = isSupported
//       self.buildVersion = buildVersion
//       self.operatingSystemVersion = operatingSystemVersion
//       self.installer = installer
//   }
   init(imageMetadata : ImageMetadata) {
       self.init(isSupported: imageMetadata.isImageSupported, buildVersion: imageMetadata.buildVersion, operatingSystemVersion: imageMetadata.operatingSystemVersion, sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 1600000000000, lastModified: Date(), installer: imageMetadata)

       
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
    
         func beginLoad () {
            VZMacOSRestoreImage.load(from: sourceFileURL) { result in
                self.restoreImageResult = result.map(RestoreImage.init(imageMetadata:))
            }
        }
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
