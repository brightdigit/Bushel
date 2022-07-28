

public struct RestoreImageLibrary : Codable {
  public init(items: [RestoreImageLibraryItemFile] = .init()) {
    self.items = items
  }
  
  public var items : [RestoreImageLibraryItemFile]
}
