//
//  BshIllApp.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

@main
struct BshIllApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MachineDocument()) { file in
            MachineView(document: file.$document)
        }.commands {
            CommandMenu("Machines") {
                Button("Import Machine...") {
                    
                }
            }
        }
        DocumentGroup(viewing: RestoreImageDocument.self) { file in
            RestoreImageView(document: file.$document)
        }.commands {
            CommandMenu("Images") {
                Button("Restore Image...") {
                    
                }
            }
        }
        WindowGroup(Text("Images")) {
            ImageCollectionView()
        }.windowStyle(.hiddenTitleBar).windowToolbarStyle(.unifiedCompact)
    }
}
