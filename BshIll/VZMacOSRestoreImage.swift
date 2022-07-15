




extension VZMacOSRestoreImage {
  var isImageSupported: Bool {
#if swift(>=5.7)
    if #available(macOS 13.0, *) {
      return self.isSupported
    } else {
      return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
    }
#else
    return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
#endif
  }
}

extension VZMacOSRestoreImage : ImageInstaller {
  
  func headers (withSession session: URLSession = .shared) async throws -> [AnyHashable : Any] {
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    let (_, response) = try await session.data(for: request)
    
    guard let response = response as? HTTPURLResponse else {
      throw MissingError.needDefinition(response)
    }
    
    return response.allHeaderFields
  }
  //    var isImageSupported: Bool {
  //        if #available(macOS 13.0, *) {
  //            return self.isSupported
  //        } else {
  //            return self.mostFeaturefulSupportedConfiguration?.hardwareModel.isSupported == true
  //        }
  //    }
}


extension VZMacOSRestoreImage {
  static func fetchLatestSupported () async throws -> VZMacOSRestoreImage {
    try await withCheckedThrowingContinuation({ continuation in
      self.fetchLatestSupported { result in
        continuation.resume(with: result)
      }
    })
  }
  
  static func loadFromURL(_ url: URL) async throws -> VZMacOSRestoreImage {
    try await withCheckedThrowingContinuation({ continuation in
      self.load(from: url, completionHandler: continuation.resume(with:))
    })
  }
}
