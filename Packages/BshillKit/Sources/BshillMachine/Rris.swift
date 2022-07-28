


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
