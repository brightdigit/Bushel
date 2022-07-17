import Foundation

struct Machine : Identifiable, Codable {
  let id : UUID = UUID()
  var restoreImage : RestoreImageLibraryItemFile?
  
}
