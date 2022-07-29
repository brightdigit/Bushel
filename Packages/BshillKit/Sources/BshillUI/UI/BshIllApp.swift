//
//  BshIllApp.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers
import BshillMachine
import Virtualization

public protocol BshIllAppExt: App {
}

struct VirtualizationImageManager : ImageManager {
  
  
  func loadFromAccessor(_ accessor: FileAccessor) async throws -> VZMacOSRestoreImage {
    try await VZMacOSRestoreImage.loadFromURL(accessor.getURL())
  }
  
  func imageContainer(vzRestoreImage: VZMacOSRestoreImage, sha256: SHA256?) async throws -> ImageContainer {
    try await VirtualizationMacOSRestoreImage(vzRestoreImage: vzRestoreImage, sha256: sha256)
  }
}
public extension BshIllAppExt {
  
  func scene (@SceneBuilder builder: () -> some Scene ) -> some Scene {
    return builder()
  }
  var body: some Scene {
    scene {
      WindowGroup {
        WelcomeView()
      }.windowsHandle(.welcome).windowStyle(.hiddenTitleBar)
      DocumentGroup(newDocument: RestoreImageLibraryDocument()) { file in
        RestoreImageLibraryDocumentView(document: file.$document, url: file.fileURL)
      }
      DocumentGroup(newDocument: MachineDocument()) { file in
        MachineView(document: file.$document, url: file.fileURL, restoreImageChoices: [])
      }.commands {
        CommandGroup(replacing: .newItem) {
          Menu("New") {
            Button("New Machine") {
              Windows.showNewDocumentWindow(ofType: .virtualMachine)
            }
            Button("New Image Library") {
              Windows.showNewDocumentWindow(ofType: .restoreImageLibrary)
            }
          }
        }
        CommandGroup(after: .newItem) {
          Button("Download Restore Image...") {
            Windows.openWindow(withHandle: BasicWindowOpenHandle.remoteSources)
          }
        }
        CommandGroup(after: .windowArrangement) {
          Button("Welcome to Bshill"){
            Windows.openWindow(withHandle: BasicWindowOpenHandle.welcome)
          }
        }
      }
      DocumentGroup(viewing: RestoreImageDocument.self) { file in
        // https://stackoverflow.com/questions/67659770/how-to-read-large-files-using-swiftui-documentgroup-without-making-a-temporary-c
        RestoreImageDocumentView(document: file.document, manager: VirtualizationImageManager() , url: file.fileURL)
      }
      WindowGroup {
        RrisCollectionView()
      }.windowsHandle(.remoteSources)
    }
    //        DocumentGroup(newDocument: MachineDocument()) { file in
    //          MachineView(document: file.$document, url: file.fileURL, restoreImageChoices: [])
    //        }.commands {
    //          CommandGroup(replacing: .newItem) {
    //            Menu("New") {
    //              Button("New Machine") {
    //                Windows.showNewDocumentWindow(ofType: .virtualMachine)
    //              }
    //              Button("New Image Library") {
    //                Windows.showNewDocumentWindow(ofType: .restoreImageLibrary)
    //              }
    //            }
    //          }
    //          CommandGroup(after: .newItem) {
    //            Button("Download Restore Image...") {
    //              Windows.openWindow(withHandle: BasicWindowOpenHandle.remoteSources)
    //            }
    //          }
    //          CommandGroup(after: .windowArrangement) {
    //            Button("Welcome to Bshill"){
    //              Windows.openWindow(withHandle: BasicWindowOpenHandle.welcome)
    //            }
    //          }
    //        }
    //        DocumentGroup(viewing: RestoreImageDocument.self) { file in
    //          // https://stackoverflow.com/questions/67659770/how-to-read-large-files-using-swiftui-documentgroup-without-making-a-temporary-c
    //          RestoreImageDocumentView(document: file.document, url: file.fileURL)
    //        }
    //        WindowGroup {
    //          RrisCollectionView()
    //        }.windowsHandle(.remoteSources)
  }
  
}
