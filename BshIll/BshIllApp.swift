//
//  BshIllApp.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct BshIllApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }.windowsHandle(.welcome).windowStyle(.hiddenTitleBar)
        DocumentGroup(newDocument: RestoreImageLibraryDocument()) { file in
          RestoreImageLibraryDocumentView(document: file.$document)
        }
        DocumentGroup(newDocument: MachineDocument()) { file in
            MachineView(document: file.$document, restoreImageChoices: [])
        }.commands {
            CommandGroup(replacing: .newItem) {
                Menu("New") {
                    Button("New Machine") {
                        Self.showNewDocumentWindow(ofType: .virtualMachine)
                    }
                    Button("New Image Library") {
                        Self.showNewDocumentWindow(ofType: .restoreImageLibrary)
                    }
                }
            }
            CommandGroup(after: .newItem) {
                Button("Download Restore Image...") {
                    Self.openWindow(withHandle: .remoteSources)
                }
            }
            CommandGroup(after: .windowArrangement) {
                Button("Welcome to Bshill"){
                    Self.openWindow(withHandle: .welcome)
                }
            }
        }
        DocumentGroup(viewing: RestoreImageDocument.self) { file in
          RestoreImageDocumentView(document: file.document)
        }
        WindowGroup {
            RrisCollectionView()
        }.windowsHandle(.remoteSources)
    }
}
