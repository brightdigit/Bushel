import Foundation

struct Machine : Identifiable {
  let id : UUID = UUID()
  var restoreImage : RestoreImageLibraryItemFile?
}
