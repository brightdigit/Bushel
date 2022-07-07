//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

enum OperatingSystemCodeName : Int, CaseIterable {
    case bigSur = 11
    case monterey = 12
    case ventura = 13
    
    
    init?(operatingSystemVersion : OperatingSystemVersion) {
        self.init(rawValue: operatingSystemVersion.majorVersion)
    }
    
    static let names : [OperatingSystemCodeName : String] = [
        .bigSur : "Big Sur",
            .monterey : "Monterey",
            .ventura : "Ventura"
        
        
    ]
    var name : String {
        guard let name = Self.names[self] else {
            preconditionFailure()
        }
        return name
    }
}
extension Image {
    init(operatingSystemVersion: OperatingSystemVersion) {
        let codeName = OperatingSystemCodeName(operatingSystemVersion: operatingSystemVersion)
        let imageName = codeName?.name
        self.init(imageName ?? "Big Sur")
    }
}

struct RestoreImageDocumentView: View {
    @Binding var document: RestoreImageDocument

  
  var body: some View {
        switch document.loader.restoreImageResult {
        case .none:
            ProgressView()
        case .success(let image):
          RestoreImageView(image: image).fixedSize()
        default:
            EmptyView()
        }
    }
}

struct RestoreImageDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreImageDocumentView(document: .constant(RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil))))
        
      RestoreImageDocumentView(document: .constant(.Previews.previewLoadedDocument))
    }
}


extension RestoreImageDocument {
  enum Previews {
    static let previewLoadedDocument = RestoreImageDocument(
      loader: MockRestoreImageLoader(restoreImageResult: .success(.Previews.previewModel))
    )
    
  }
}

extension ImageMetadata {
  enum Previews {
    //static let previewModel : ImageMetadata = .init(url: URL(string: "https://updates.cdn-apple.com/2022SummerSeed/fullrestores/012-30346/9DD787A7-044B-4650-86D4-84E80B6B9C36/UniversalMac_13.0_22A5286j_Restore.ipsw")!, isImageSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 16000000000, lastModified: Date())
    static let previewModel : ImageMetadata = .init(isImageSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 16000000000, lastModified: .init(), url: URL(string: "https://updates.cdn-apple.com/2022SummerSeed/fullrestores/012-30346/9DD787A7-044B-4650-86D4-84E80B6B9C36/UniversalMac_13.0_22A5286j_Restore.ipsw")!)
  }
}
extension RestoreImage {
  
  enum Previews {
    
    static let previewModel : RestoreImage = .init(metadata: ImageMetadata.Previews.previewModel,  installer: MockInstaller())
  }
}
