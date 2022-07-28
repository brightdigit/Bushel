



public protocol RestoreImageLoader {
  
  func load<ImageManagerType : ImageManager>(from file: FileAccessor, using manager: ImageManagerType) async throws -> RestoreImage
}
