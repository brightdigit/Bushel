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
    var library: RestoreImageLibrary

    init(library : RestoreImageLibrary = .init()) {
        self.library = library
    }

    static let readableContentTypes: [UTType] = [.restoreImageLibrary] 

    init(configuration: ReadConfiguration) throws {
        self.init()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      
        return .init(directoryWithFileWrappers: [String : FileWrapper]())
    }
}
