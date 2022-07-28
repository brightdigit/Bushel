
import BshillMachine

struct MockRestoreImageLoader : RestoreImageLoader {
  func load<ImageManagerType>(from file: BshillMachine.FileAccessor, using manager: ImageManagerType) async throws -> BshillMachine.RestoreImage where ImageManagerType : BshillMachine.ImageManager {
    return try self.actualResult.get()
  }
  
  
  let actualResult : Result<RestoreImage, Error>
  
  var restoreImageResult: Result<RestoreImage, Error>? {
    return actualResult
  }
}
