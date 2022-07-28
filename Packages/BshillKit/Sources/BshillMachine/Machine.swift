import Foundation
import Virtualization

#warning("Remove `import Virtualization`")
public struct Machine : Identifiable, Codable {
  public  init(id: UUID = .init(), restoreImage: RestoreImageLibraryItemFile? = nil, operatingSystem: OperatingSystemDetails? = nil) {
    self.id = id
    self.restoreImage = restoreImage
    self.operatingSystem = operatingSystem
  }
  
  public let id : UUID
  public var restoreImage : RestoreImageLibraryItemFile?
  public var operatingSystem : OperatingSystemDetails?
  public var configurationURL: URL?
  //var fileAccessor : FileAccessor?
  
  public func createMachine () throws -> MachineSession {
    guard self.operatingSystem?.type == .macOS else {
      throw NSError()
    }
    guard let url = self.configurationURL else {
      throw NSError()
    }
    let configuration = try VZVirtualMachineConfiguration(contentsOfDirectory: url)
    try configuration.validate()
    return VZVirtualMachine(configuration: configuration)
    
  }
  //var fileWrapper : FileWrapper?
public  var isBuilt : Bool {
    guard operatingSystem != nil else {
      return false
    }
    
    guard let installerType = restoreImage?.installerType else {
      return false
    }
    
    guard let configurationURL = configurationURL else {
      return false
    }
//    guard let fileWrapper = self.fileWrapper else {
//      return false
//    }
    
    return installerType.validateAt(configurationURL)
  }
  
  enum CodingKeys : String, CodingKey {
    case id
    case restoreImage
    case configurationURL
    case operatingSystem
  }
  
  public mutating func setConfiguration(_ configuration: MachineConfiguration) {
    self.configurationURL = configuration.currentURL
  }
  
  mutating func osInstallationCompleted (withConfiguration configuration: MachineConfiguration) {
    guard let metadata = self.restoreImage?.metadata else {
      return
    }
    self.setConfiguration(configuration)
    self.operatingSystem = .init(type: .macOS, version: metadata.operatingSystemVersion, buildVersion: metadata.buildVersion)
  }
  
  mutating func beginLoadingFromURL(_ url: URL) {
    self.configurationURL = url
    
    
  }
  //var configuration : MachineConfiguration?
  //var installer : ImageInstaller?
}

extension Machine {
  public func createInstaller () async throws -> ImageInstaller {
    guard let restoreImage = self.restoreImage else {
      throw NSError()
    }
    return try await restoreImage.installer()
  }
  public func build (withInstaller installer: ImageInstaller)  throws  -> MachineConfiguration {
    
      return try installer.setupMachine(self)
    
  }
  
  public  func startInstallation (with installer: ImageInstaller, using configuration: MachineConfiguration) throws -> VirtualInstaller {
   
      return try installer.beginInstaller(configuration: configuration)
    
  }
}
