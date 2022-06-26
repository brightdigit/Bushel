//
//  BshIllApp.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

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
    case remoteImages
    
}

@main
struct BshIllApp: App {
    var body: some Scene {
        
        DocumentGroup(newDocument: MachineDocument()) { file in
            MachineView(document: file.$document, restoreImageChoices: [])
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Import Machine...") {
                    
                }
                Button("Restore Image...") {
                    
                }
                
            }
        }
        DocumentGroup(newDocument: RestoreImageLibraryDocument()) { file in
            RestoreImageLibraryDocumentView(document: file.$document)
        }
        DocumentGroup(viewing: RestoreImageDocument.self) { file in
            RestoreImageView(document: file.$document)
        }
        WindowGroup(Text("Images")) {
            ImageCollectionView()
        }.windowStyle(.hiddenTitleBar).windowToolbarStyle(.unifiedCompact)
    }
}
