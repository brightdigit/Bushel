

struct RestoreImageLibraryItemFile : Codable, Identifiable, Hashable {
  
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
  
  
  enum CodingKeys : String, CodingKey {
    case name
    case metadata
    
  }
  
  init (name : String? = nil, metadata : ImageMetadata, location: RestoreImage.Location = .library) {
    self.name = name ?? metadata.url.deletingPathExtension().lastPathComponent
    self.metadata = metadata
    self.location = location
  }
  
  
  init (restoreImage: RestoreImage) {
    self.init(metadata: restoreImage.metadata, location: restoreImage.location)
  }
}
