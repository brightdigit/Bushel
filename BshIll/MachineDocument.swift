//
//  BshIllDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers



struct MachineDocument: CreatableFileDocument {
    var machine: Machine

    init(machine : Machine = .init()) {
        self.machine = machine
    }

  static let untitledDocumentType: UTType = .virtualMachine
    static let readableContentTypes: [UTType] = [.virtualMachine] 

    init(configuration: ReadConfiguration) throws {
        self.init()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        
        return .init(directoryWithFileWrappers: [String : FileWrapper]())
    }
}
