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
    
    static let baseURLComponents = {
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
    
}

extension App {
    func showNewDocumentWindow(ofType type: UTType) {
        
            let dc = NSDocumentController.shared
            if let newDocument = try? dc.makeUntitledDocument(ofType: type.identifier) {
            dc.addDocument(newDocument)
            newDocument.makeWindowControllers()
            newDocument.showWindows()
          }
    }
}
@main
struct BshIllApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        DocumentGroup(newDocument: RestoreImageLibraryDocument()) { file in
            RestoreImageLibraryDocumentView(document: file.$document)
        }
        DocumentGroup(newDocument: MachineDocument()) { file in
            MachineView(document: file.$document, restoreImageChoices: [])
        }.commands {
            CommandGroup(replacing: .newItem) {
                Menu("New") {
                    Button("New Machine") {
                        self.showNewDocumentWindow(ofType: .virtualMachine)
                    }
                    Button("New Image Library") {
                        self.showNewDocumentWindow(ofType: .restoreImageLibrary)
                    }
                }
            }
            CommandGroup(after: .newItem) {
                Button("Download Restore Image...") {
                    NSWorkspace.shared.open(URL(forHandle: .remoteSources))
                }
            }
        }
        DocumentGroup(viewing: RestoreImageDocument.self) { file in
            RestoreImageView(document: file.$document)
        }
        WindowGroup {
            RrisCollectionView()
        }.handlesExternalEvents(matching: .init([WindowOpenHandle.remoteSources.rawValue]))
    }
}
