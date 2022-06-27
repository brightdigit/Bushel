//
//  RrisCollectionView.swift
//  BshIll
//
//  Created by Leo Dion on 6/26/22.
//

import SwiftUI
import Virtualization

struct Rris : Identifiable {
    let id : String
    let title : String
    let fetch : () async throws -> [RestoreImage]
    
    
}

extension Rris {
    static let apple : Rris = .init(id: "apple", title: "Apple") {
        try await withCheckedThrowingContinuation { continuation in
            VZMacOSRestoreImage.fetchLatestSupported { result in
                continuation.resume(with: result.map(RestoreImage.init(imageMetadata:)).map{[$0]})
                
            }
        }
    }
}

struct RrisCollectionView: View {
    let sources: [Rris] = [
        .apple
    ]
    var body: some View {
        List{
            ForEach(sources) { source in
                Text(source.title)
            }
        }
    }
}

struct RrisCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RrisCollectionView()
    }
}
