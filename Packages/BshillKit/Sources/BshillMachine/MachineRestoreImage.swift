import Foundation

public struct MachineRestoreImage : Hashable, Identifiable {
  public  init (file: RestoreImageLibraryItemFile) {
    self.id = file.id
    self.name = file.name
    self.image = RestoreImage(imageContainer: file)
  }
  public  init(name: String, id: String, image: RestoreImage? = nil) {
    self.name = name
    self.id =  id.data(using: .utf8)!
    self.image = image
  }
  
  public let name : String
  public  let id : Data
  
  public let image : RestoreImage?
}
