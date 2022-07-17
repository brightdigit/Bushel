import Foundation
import UniformTypeIdentifiers

extension FileManager {
  func createTemporaryFile(for type: UTType) -> URL {
    let tempFile : URL
    //
#if swift(>=5.7)
    if #available(macOS 13.0, *) {
      tempFile = self.temporaryDirectory.appending(path: UUID().uuidString).appendingPathExtension(for: type)
    } else {
      tempFile = self.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(for: type)
    }
#else
    tempFile = self.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(for: type)
#endif
    return tempFile
  }
//  func createTemporaryFileWithData(_ data: Data, extension: String) -> URL {
//    let tempFile = createTemporaryFileWithExtension("")
//#if swift(>=5.7)
//    if #available(macOS 13.0, *) {
//      self.createFile(atPath: tempFile.path(), contents: data)
//    } else {
//      self.createFile(atPath: tempFile.path, contents: data)
//    }
//#else
//    self.createFile(atPath: tempFile.path, contents: data)
//#endif
//    return tempFile
//  }
}



extension FileManager {
  func directoryExists(at url: URL) -> DirectoryExists {
    
    var isDirectory : ObjCBool = false
    let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    
    return .init(fileExists: fileExists, isDirectory: isDirectory.boolValue)
  }
}
