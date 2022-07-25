
import Virtualization
import Combine


extension VZMacPlatformConfiguration {
    convenience init(fromDirectory machineDirectory: URL) throws {
        self.init()
        let auxiliaryStorageURL = machineDirectory.appendingPathComponent("auxiliary.storage")
        let hardwareModelURL = machineDirectory.appendingPathComponent("hardware.model.bin")
        let machineIdentifierURL = machineDirectory.appendingPathComponent("machine.identifier.bin")
        if #available(macOS 13.0, *) {
            self.auxiliaryStorage = VZMacAuxiliaryStorage(url: auxiliaryStorageURL)
        } else {
            self.auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: auxiliaryStorageURL)
            // Fallback on earlier versions
        }
        
        guard let hardwareModel = VZMacHardwareModel(dataRepresentation: try Data(contentsOf: hardwareModelURL) ) else {
            throw NSError()
        }
        self.hardwareModel = hardwareModel
        guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: try .init(contentsOf: machineIdentifierURL)) else {
            throw NSError()
        }
        self.machineIdentifier = machineIdentifier
    }
    convenience init(restoreImage : VZMacOSRestoreImage, in machineDirectory: URL) throws
    {
        self.init()
        
        
        guard let configuration = restoreImage.mostFeaturefulSupportedConfiguration else {
          throw NSError()
        }
        
        try FileManager.default.createDirectory(at: machineDirectory, withIntermediateDirectories: true)
        let auxiliaryStorageURL = machineDirectory.appendingPathComponent("auxiliary.storage")
        let hardwareModelURL = machineDirectory.appendingPathComponent("hardware.model.bin")
        let machineIdentifierURL = machineDirectory.appendingPathComponent("machine.identifier.bin")
        
        let auxiliaryStorage = try VZMacAuxiliaryStorage(creatingStorageAt: auxiliaryStorageURL,
                                                          hardwareModel: configuration.hardwareModel,
                                                                options: [])
        
        self.auxiliaryStorage = auxiliaryStorage
        self.hardwareModel = configuration.hardwareModel
        self.machineIdentifier = .init()
        
        try self.hardwareModel.dataRepresentation.write(to: hardwareModelURL)
        try self.machineIdentifier.dataRepresentation.write(to: machineIdentifierURL)
    }
}

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

protocol MachineConfiguration {
  var currentURL : URL { get }
  
}
protocol VirtualInstaller {
  func completionPublisher() -> AnyPublisher<Error?, Never>
  func progressPublisher<Value>(forKeyPath keyPath: KeyPath<Progress, Value>) -> AnyPublisher<Value, Never>
  func begin ()
}
struct VirtualMachineConfiguration : MachineConfiguration {
  let vzMachineConfiguration : VZVirtualMachineConfiguration
  let currentURL : URL
}
class VirtualMacOSInstallerPublisher : VirtualInstaller {
  internal init(vzInstaller: VZMacOSInstaller) {
    self.vzInstaller = vzInstaller
    self.beginTrigger = PassthroughSubject()
    self.installationResultSubject = PassthroughSubject()
    self.cancellable = self.beginTrigger.flatMap {
      return Future { completed in
        self.vzInstaller.install { result in
          completed(.success(result))
        }
      }
    }.subscribe(self.installationResultSubject)
  }
  
  let vzInstaller : VZMacOSInstaller
  let beginTrigger : PassthroughSubject<Void, Never>
  let installationResultSubject : PassthroughSubject<Result<Void, Error>, Never>
  var cancellable : AnyCancellable!
  
  func progressPublisher<Value>(forKeyPath keyPath: KeyPath<Progress, Value>) -> AnyPublisher<Value, Never> {
    return vzInstaller.progress.publisher(for: keyPath, options: [.new, .initial]).eraseToAnyPublisher()
  }
  
  func completionPublisher() -> AnyPublisher<Error?, Never> {
    return self.installationResultSubject.map { result in
      guard case let .failure(error) = result else {
        return nil
      }
      return error
    }.eraseToAnyPublisher()
  }
  
  func begin () {
    self.beginTrigger.send()
  }
  
}
extension VZMacOSRestoreImage : ImageInstaller {
  func setupMachine(_ machine: Machine) throws -> MachineConfiguration {
    let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true)
    let configuration = try VZVirtualMachineConfiguration(restoreImage: self, in: temporaryURL)
    try configuration.validate()
    return VirtualMachineConfiguration(vzMachineConfiguration: configuration, currentURL: temporaryURL)
  }
  func beginInstaller(configuration: MachineConfiguration) throws  -> VirtualInstaller  {
    guard let vzConfig = (configuration as? VirtualMachineConfiguration)?.vzMachineConfiguration else {
      throw NSError()
    }
    let machine = VZVirtualMachine(configuration: vzConfig)
    let installer = VZMacOSInstaller(virtualMachine: machine, restoringFromImageAt: self.url)
    let publisher =  VirtualMacOSInstallerPublisher(vzInstaller: installer)
    publisher.begin()
    return publisher
  }
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
