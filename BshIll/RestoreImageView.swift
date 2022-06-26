//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

struct RestoreImageView: View {
    @Binding var document: RestoreImageDocument
    var body: some View {
        switch document.loader.restoreImageResult {
        case .none:
            ProgressView()
        case .success(let image):
            VStack{
                Text(image.operatingSystemVersion.description)
                Text(image.buildVersion.description)
            }
        default:
            EmptyView()
        }
    }
}

struct RestoreImageView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreImageView(document: .constant(RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil))))
        
        RestoreImageView(document: .constant(RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: .success(.init(isSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), installer: MockInstaller()))))))
    }
}
