//
//  File.swift
//  
//
//  Created by Leo Dion on 7/28/22.
//

import Foundation
import Virtualization

public extension Rris {
    static let apple : Rris = .init(id: "apple", title: "Apple") {
      let vzRestoreImage = try await VZMacOSRestoreImage.fetchLatestSupported()
      let virRestoreImage = try await VirtualizationMacOSRestoreImage(vzRestoreImage: vzRestoreImage, sha256: nil)
      return [RestoreImage(imageContainer: virRestoreImage)]
    }
}
