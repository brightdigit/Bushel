import SwiftUI

extension FileWrapper : FileAccessor {
  func getData() -> Data? {
    return self.regularFileContents
  }
  
  func writeTo(_ url: URL) throws {
    try self.write(to: url, originalContentsURL: nil)
  }
}
