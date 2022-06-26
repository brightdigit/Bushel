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
    
}

protocol ImageInstaller {
    
}

protocol ImageMetadata : ImageInstaller {
    var isSupported : Bool { get }
        var buildVersion : String { get }
            var operatingSystemVersion : OperatingSystemVersion { get }
}

struct MockInstaller : ImageInstaller {
    
}

protocol RestoreImageFactory {
    //func restoreImage(
}
struct RestoreImage {
    
    let isSupported : Bool
    let buildVersion : String
    let operatingSystemVersion : OperatingSystemVersion
    
    
    let installer : ImageInstaller
    init(isSupported: Bool, buildVersion: String, operatingSystemVersion: OperatingSystemVersion, installer: ImageInstaller) {
       self.isSupported = isSupported
       self.buildVersion = buildVersion
       self.operatingSystemVersion = operatingSystemVersion
       self.installer = installer
   }
   init(imageMetadata : ImageMetadata) {
       self.init(isSupported: imageMetadata.isSupported, buildVersion: imageMetadata.buildVersion, operatingSystemVersion: imageMetadata.operatingSystemVersion, installer: imageMetadata)
       
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
        let tempFile = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        FileManager.default.createFile(atPath: tempFile.path(), contents: data)
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
