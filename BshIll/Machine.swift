import Foundation


struct OperatingSystemDetails : Codable {
  enum System : String, Codable {
    case macOS
  }
  let type : System
  let version: OperatingSystemVersion
  let buildVersion : String
}
struct Machine : Identifiable, Codable {
  internal init(id: UUID = .init(), restoreImage: RestoreImageLibraryItemFile? = nil, operatingSystem: OperatingSystemDetails? = nil) {
    self.id = id
    self.restoreImage = restoreImage
    self.operatingSystem = operatingSystem
  }
  
  let id : UUID
  var restoreImage : RestoreImageLibraryItemFile?
  var operatingSystem : OperatingSystemDetails?
  var configurationURL: URL?
  var fileWrapper : FileWrapper?
  var isBuilt : Bool {
    guard operatingSystem != nil else {
      return false
    }
    
    guard let installerType = restoreImage?.installerType else {
      return false
    }
    
    guard let fileWrapper = self.fileWrapper else {
      return false
    }
    
    return installerType.validate(fileWrapper: fileWrapper)
  }
  
  enum CodingKeys : String, CodingKey {
    case id
    case restoreImage
    case operatingSystem
  }
  
  mutating func setConfiguration(_ configuration: MachineConfiguration) {
    self.configurationURL = configuration.currentURL
  }
  
  mutating func osInstallationCompleted () {
    guard let metadata = self.restoreImage?.metadata else {
      return
    }
    self.operatingSystem = .init(type: .macOS, version: metadata.operatingSystemVersion, buildVersion: metadata.buildVersion)
  }
  
  mutating func beginLoading() {
    guard let fileWrapper = self.fileWrapper else {
      return
    }
  }
  //var configuration : MachineConfiguration?
  //var installer : ImageInstaller?
}

class MachineInstallationObject : ObservableObject {
  @Published var installer : VirtualInstaller?
  @Published var isCompletedWithError : Result<Void, Error>?
  @Published var progressValue : Double = 0
  
  init () {
    let vInstaller = $installer.compactMap{$0}
    
    let combinedPublishers = vInstaller.map { installer in
      return (installer.progressPublisher(forKeyPath: \.fractionCompleted),installer.completionPublisher())
    }
    
    let progressPublisher = combinedPublishers.share().map(\.0).switchToLatest()
    let completedPublisher = combinedPublishers.share().map(\.1).switchToLatest()
    
    progressPublisher.assign(to: &self.$progressValue)
    completedPublisher.map { error in
      let result : Result<Void, Error>?
      result = error.map(Result.failure) ?? Result.success(())
      return result
    }.assign(to: &self.$isCompletedWithError)
  }
  
  func setupInstaller (_ installer: VirtualInstaller) {
    Task {
      await MainActor.run {
        self.installer = installer
      }
    }
  }
}
extension Machine {
  func createInstaller () async throws -> ImageInstaller {
    guard let restoreImage = self.restoreImage else {
      throw NSError()
    }
    return try await restoreImage.installer()
  }
  func build (withInstaller installer: ImageInstaller)  throws  -> MachineConfiguration {
    
      return try installer.setupMachine(self)
    
  }
  
  func startInstallation (with installer: ImageInstaller, using configuration: MachineConfiguration) throws -> VirtualInstaller {
   
      return try installer.beginInstaller(configuration: configuration)
    
  }
}
