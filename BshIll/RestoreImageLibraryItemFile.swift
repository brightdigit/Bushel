import Foundation
import Virtualization

enum InstallerType : String, Codable {
  case vzMacOS
}

extension InstallerType {
  func validate (fileWrapper: FileWrapper) -> Bool {
    return true
  }
}
struct RestoreImageLibraryItemFile : Codable, Identifiable, Hashable, ImageContainer {
  
  func installer() async throws -> ImageInstaller {
    return try await VZMacOSRestoreImage.loadFromURL(self.metadata.url)
  }
  
  static func == (lhs: RestoreImageLibraryItemFile, rhs: RestoreImageLibraryItemFile) -> Bool {
    lhs.id == rhs.id
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Self.CodingKeys)
    let name = try container.decode(String.self, forKey: .name)
    let metadata = try container.decode(ImageMetadata.self, forKey: .metadata)
    self.init(name: name, metadata: metadata, location: .library)
  }
  
  var id: Data {
    self.metadata.url.dataRepresentation
  }
  
  var name : String
  let metadata : ImageMetadata
  let location : RestoreImage.Location
  var fileWrapper : FileWrapper?
  let installerType : InstallerType = .vzMacOS
  
  enum CodingKeys : String, CodingKey {
    case name
    case metadata
    case installerType
  }
  
  init (name : String? = nil, metadata : ImageMetadata, location: RestoreImage.Location = .library, fileWrapper : FileWrapper? = nil) {
    self.name = name ?? metadata.url.deletingPathExtension().lastPathComponent
    self.metadata = metadata
    self.location = location
    self.fileWrapper = fileWrapper
  }
  
  
  init (restoreImage: RestoreImage) {
    self.init(metadata: restoreImage.metadata, location: restoreImage.location)
  }
}


extension RestoreImageLibraryItemFile {
  func forMachine () throws -> RestoreImageLibraryItemFile {
    guard let fileWrapper = self.fileWrapper else {
      throw NSError()
    }
    let temporaryFileURL = FileManager.default.createTemporaryFile(for: .iTunesIPSW)
    try fileWrapper.writeTo(temporaryFileURL)
    return RestoreImageLibraryItemFile(name: self.name, metadata: self.metadata.withURL(temporaryFileURL))
  }
}
