
import Combine
import Foundation


public protocol VirtualInstaller {
  func completionPublisher() -> AnyPublisher<Error?, Never>
  func progressPublisher<Value>(forKeyPath keyPath: KeyPath<Progress, Value>) -> AnyPublisher<Value, Never>
  func begin ()
}
