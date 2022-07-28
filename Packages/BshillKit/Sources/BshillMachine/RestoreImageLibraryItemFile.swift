import Foundation
import Virtualization
#warning("Remove `import Virtualization`")

public struct RestoreImageLibraryItemFile : Codable, Identifiable, Hashable, ImageContainer {
  public func updatingWithURL(_ url: URL, andFileAccessor newFileAccessor: FileAccessor?) -> RestoreImageLibraryItemFile {
    let fileAccessor : FileAccessor?
    
    if let newFileAccessor = newFileAccessor {
      fileAccessor = newFileAccessor
    } else if let oldFileAccessor = self.fileAccessor {
      fileAccessor = oldFileAccessor.updatingWithURL(url, sha256: self.metadata.sha256)
    } else {
      fileAccessor = nil
    }
    
    return RestoreImageLibraryItemFile(name: self.name, metadata: self.metadata.withURL(url), location: .library, fileAccessor: fileAccessor)
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(metadata)
    hasher.combine(location)
    hasher.combine(installerType)
  }
  public  func installer() async throws -> ImageInstaller {
    return try await self.installerType.loadFromURL(self.metadata.url)
  }
  
  public static func == (lhs: RestoreImageLibraryItemFile, rhs: RestoreImageLibraryItemFile) -> Bool {
    lhs.id == rhs.id
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Self.CodingKeys)
    let name = try container.decode(String.self, forKey: .name)
    let metadata = try container.decode(ImageMetadata.self, forKey: .metadata)
    self.init(name: name, metadata: metadata, location: .library)
  }
  
  public var id: Data {
    self.metadata.url.dataRepresentation
  }
  
  public var name : String
  public let metadata : ImageMetadata
  let location : RestoreImage.Location
  public var fileAccessor : FileAccessor?
  let installerType : InstallerType = .vzMacOS
  
  enum CodingKeys : String, CodingKey {
    case name
    case metadata
    case installerType
  }
  
 public init (name : String? = nil, metadata : ImageMetadata, location: RestoreImage.Location = .library, fileAccessor : FileAccessor? = nil) {
    self.name = name ?? metadata.url.deletingPathExtension().lastPathComponent
    self.metadata = metadata
    self.location = location
    self.fileAccessor = fileAccessor
  }
  
  
  public init (restoreImage: RestoreImage) {
    self.init(metadata: restoreImage.metadata, location: restoreImage.location)
  }
}


public extension RestoreImageLibraryItemFile {
  func forMachine () throws -> RestoreImageLibraryItemFile {
    guard let fileAccessor = self.fileAccessor else {
      throw NSError()
    }
    let temporaryFileURL = try fileAccessor.getURL()
    return RestoreImageLibraryItemFile(name: self.name, metadata: self.metadata.withURL(temporaryFileURL))
  }
}
