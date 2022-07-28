import Virtualization


public struct Rris : Identifiable, Hashable {
  public static func == (lhs: Rris, rhs: Rris) -> Bool {
        lhs.id == rhs.id
    }
    
  public let id : String
  public let title : String
  public let fetch : () async throws -> [RestoreImage]
    
  public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}


public extension Rris {
    static let apple : Rris = .init(id: "apple", title: "Apple") {
      let vzRestoreImage = try await VZMacOSRestoreImage.fetchLatestSupported()
      let virRestoreImage = try await VirtualizationMacOSRestoreImage(vzRestoreImage: vzRestoreImage, sha256: nil)
      return [RestoreImage(imageContainer: virRestoreImage)]
//        try await withCheckedThrowingContinuation { continuation in
//            VZMacOSRestoreImage.fetchLatestSupported { result in
//              result.map(Virt)
//                continuation.resume(with: result.map(RestoreImage.init(imageMetadata:)).map{[$0]})
//
//            }
//        }
    }
}
