//
//  BshIllDocument.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers



struct MachineDocument: CreatableFileDocument, Identifiable {
  var machine: Machine
  
  var id: UUID {
    machine.id
  }
  
  init(machine : Machine = .init()) {
    self.machine = machine
  }
  
  
  static let untitledDocumentType: UTType = .virtualMachine
  static let readableContentTypes: [UTType] = [.virtualMachine]
  
  init(configuration: ReadConfiguration) throws {
    self.init()
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    var fileWrapper : FileWrapper
    let existingFile = configuration.existingFile
    if let configurationURL = machine.configurationURL {
      fileWrapper = try FileWrapper(url: configurationURL)
    } else {
      fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }
    guard fileWrapper.isDirectory else {
      throw NSError()
    }
    let encoder = JSONEncoder()
    let data = try encoder.encode(self.machine)
    let machineFileWrapper = FileWrapper(regularFileWithContents: data)
    machineFileWrapper.preferredFilename = "machine.json"
    fileWrapper.addFileWrapper(machineFileWrapper)
    
    return fileWrapper
  }
}
