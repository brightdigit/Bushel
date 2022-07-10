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
  internal init(_ fetchImage : @escaping () async throws -> RestoreImage) {
    self.fetchImage = fetchImage
  }
  internal init(document: RestoreImageDocument, loader: RestoreImageLoader = FileRestoreImageLoader()) {
    self.init {
      try await loader.load(from: document.fileWrapper)
    }
  }
  
//   let document: RestoreImageDocument
//  let loader : RestoreImageLoader
  let fetchImage : () async throws -> RestoreImage
  @State var restoreImageResult : Result<RestoreImage, Error>?
  
  var body: some View {
    Group{
      switch self.restoreImageResult {
      case .none:
        ProgressView()
      case .success(let image):
        RestoreImageView(image: image).fixedSize()
      default:
        EmptyView()
      }
    }
    .onAppear{
      Task {
        let restoreImageResult : Result<RestoreImage, Error>
        do {
          let image = try await self.fetchImage()
          restoreImageResult = .success(image)
        } catch {
          restoreImageResult = .failure(error)
        }
        DispatchQueue.main.async {
          self.restoreImageResult = restoreImageResult
        }
      }
       
    }
    }
}

struct RestoreImageDocumentView_Previews: PreviewProvider {
    static var previews: some View {
      RestoreImageDocumentView {
        return .Previews.usingMetadata(.Previews.venturaBeta3)
      }
//        RestoreImageDocumentView(document: RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil)))
//
//      RestoreImageDocumentView(document: .Previews.previewLoadedDocument)
      //EmptyView()
    }
}


extension RestoreImageDocument {
  enum Previews {
    //static let previewLoadedDocument = RestoreImageDocument(configuration: <#T##RestoreImageDocument.ReadConfiguration#>)
//    RestoreImageDocument(
//      loader: MockRestoreImageLoader(restoreImageResult: .success(.Previews.previewModel))
//    )
  }
}

extension ImageMetadata {
  enum Previews {
    //static let previewModel : ImageMetadata = .init(url: URL(string: "https://updates.cdn-apple.com/2022SummerSeed/fullrestores/012-30346/9DD787A7-044B-4650-86D4-84E80B6B9C36/UniversalMac_13.0_22A5286j_Restore.ipsw")!, isImageSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 16000000000, lastModified: Date())
    static let previewModel : ImageMetadata = .init(isImageSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 16000000000, lastModified: .init(), url: URL(string: "https://updates.cdn-apple.com/2022SummerSeed/fullrestores/012-30346/9DD787A7-044B-4650-86D4-84E80B6B9C36/UniversalMac_13.0_22A5286j_Restore.ipsw")!)
    
    static let venturaBeta3 = ImageMetadata(isImageSupported: true, buildVersion: "22A5295h", operatingSystemVersion: OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0), sha256: SHA256(base64Encoded: "LbNHYPVKVKpwXUmqZInQ1Nr9gaYni4IKjelvzpl72LI=")!, contentLength: 0, lastModified: Date(timeIntervalSinceReferenceDate: 679094144.0), url: URL(string: "file:///var/folders/5d/8rl1m9ts5r96dxdh4rp_zx100000gn/T/com.brightdigit.BshIll/B6844821-A5C8-42B5-80C2-20F815FB920E.ipsw")!)
  }
}
extension RestoreImage {
  
  enum Previews {
    // ImageMetadata(isImageSupported: true, buildVersion: "true", operatingSystemVersion: OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0, sha256: SHA256(base64Encoded: "LbNHYPVKVKpwXUmqZInQ1Nr9gaYni4IKjelvzpl72LI=")!, contentLength: 0, lastModified: 2022-07-09 21:15:44 +0000, url: file:///var/folders/5d/8rl1m9ts5r96dxdh4rp_zx100000gn/T/com.brightdigit.BshIll/B6844821-A5C8-42B5-80C2-20F815FB920E.ipsw
    static func  usingMetadata(_ metadata: ImageMetadata) -> RestoreImage {
      .init(metadata: metadata, installer: MockInstaller())
    }
  }
}
