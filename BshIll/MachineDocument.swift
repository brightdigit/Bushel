//
//  BshIllDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct Machine {
    
}

extension UTType {
    static var virtualMachine: UTType {
        UTType(importedAs: "com.brightdigit.bshill-vm")
    }
}

struct MachineDocument: FileDocument {
    var machine: Machine

    init(machine : Machine = .init()) {
        self.machine = machine
    }

    static let readableContentTypes: [UTType] = [.virtualMachine] 

    init(configuration: ReadConfiguration) throws {
        self.init()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        
        return .init(directoryWithFileWrappers: [String : FileWrapper]())
    }
}
