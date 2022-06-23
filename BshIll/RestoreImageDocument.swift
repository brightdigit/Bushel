//
//  RestoreImageDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    //[.init("com.apple.itunes.ipsw")!, .init("com.apple.iphone.ipsw")!]
    static let iTunesIPSW : UTType = .init("com.apple.itunes.ipsw")!
    static let iPhoneIPSW : UTType = .init("com.apple.iphone.ipsw")!
    
    static let ipswTypes = [iTunesIPSW, iPhoneIPSW]
}

struct RestoreImageDocument: FileDocument {
    static let readableContentTypes = UTType.ipswTypes
    
    init() {
        
    }
    
    init(configuration: ReadConfiguration) throws {
        fatalError()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        fatalError()
    }
    
}
