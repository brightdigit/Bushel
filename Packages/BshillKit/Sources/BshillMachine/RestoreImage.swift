import Foundation

public struct RestoreImage : Identifiable, Hashable {
  public static func == (lhs: RestoreImage, rhs: RestoreImage) -> Bool {
    lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  
  
  
  public let id : UUID = UUID()
  
  //    let isSupported : Bool
  //    let buildVersion : String
  //    let operatingSystemVersion : OperatingSystemVersion
  //    let sha256 : SHA256
  //      let contentLength : Int
  //    let lastModified: Date
  
  let installer : () async throws -> ImageInstaller
  public   let metadata : ImageMetadata
public  init(metadata : ImageMetadata, installer: @escaping () async throws -> ImageInstaller) {
    self.metadata = metadata
    self.installer = installer
  }
  
  public init(imageContainer: ImageContainer) {
    self.init(metadata: imageContainer.metadata, installer: imageContainer.installer)
  }
  
}

public extension RestoreImage {
  
  enum Location {
    case library
    case local
    case remote
    case reloaded
  }
  var location : Location {
    let url = self.metadata.url
    if url.isFileURL == true {
#warning("fix to allow subfolders under `Restore Images`")
      let directoryURL = url.deletingLastPathComponent()
      guard directoryURL.lastPathComponent == "Restore Images"  else {
        return .local
      }
      guard directoryURL.deletingLastPathComponent().pathExtension == "bshrilib" else {
        return .local
      }
      return .library
    } else {
      return .remote
    }
  }
}

