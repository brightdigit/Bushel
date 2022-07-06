//
//  BshIllApp.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers

enum Configuration {
    
    static let scheme = "bshill"
    
  static let baseURLComponents : URLComponents = {
        var components = URLComponents()
        components.scheme = Self.scheme
        return components
    }()
    
}
extension URL {
    init (forHandle handle: WindowOpenHandle) {
        var components = Configuration.baseURLComponents
        components.path = handle.rawValue
        guard let url = components.url else {
            preconditionFailure()
        }
        self = url
    }
}
enum WindowOpenHandle : String, CaseIterable {
    case machine
    case localImages
    case remoteSources
    case welcome
}

extension App {
    static func showNewDocumentWindow(ofType type: UTType) {
        
        let dc = NSDocumentController.shared
        if let newDocument = try? dc.makeUntitledDocument(ofType: type.identifier) {
            dc.addDocument(newDocument)
            newDocument.makeWindowControllers()
            newDocument.showWindows()
            
            
        }
    }
    
    static func openDocumentAtURL(_ url: URL, andDisplay display: Bool = true) {
        
        let dc = NSDocumentController.shared
        dc.openDocument(withContentsOf: url, display: display) { document, alreadyDisplayed, error in
            if let document = document {
                guard !alreadyDisplayed else {
                    return
                }
                dc.addDocument(document)
                document.makeWindowControllers()
                document.showWindows()
            }
        }
    }
    
    static func openWindow(withHandle handle: WindowOpenHandle) {
        NSWorkspace.shared.open(URL(forHandle: handle))
    }
}

extension Scene {
    func windowsHandle(_ handle: WindowOpenHandle) -> some Scene {
        self.handlesExternalEvents(matching: .init([handle.rawValue]))
    }
}
@main
struct BshIllApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }.windowsHandle(.welcome)
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
            RestoreImageDocumentView(document: file.$document)
        }
        WindowGroup {
            RrisCollectionView()
        }.windowsHandle(.remoteSources)
    }
}
