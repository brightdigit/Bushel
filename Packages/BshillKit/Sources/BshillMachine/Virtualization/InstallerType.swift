import Foundation
import Virtualization
enum InstallerType : String, Codable {
  case vzMacOS
}

extension InstallerType {
  func validateAt (_ url: URL) -> Bool {
    return true
  }
  
  func loadFromURL(_ url: URL) async throws -> ImageInstaller {
    switch self {
    case .vzMacOS:
      return try await VZMacOSRestoreImage.loadFromURL(url)
    }
  }
}
