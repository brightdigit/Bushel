import Foundation
import Virtualization

extension VZVirtualMachine : MachineSession {
  @MainActor
  public func begin() async throws {
    try await withCheckedThrowingContinuation { continuation in
      
      self.start { result in
        continuation.resume(with: result)
      }
    }
  }
}
