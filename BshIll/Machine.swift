import Foundation


struct OperatingSystemDetails : Codable {
  enum System : String, Codable {
    case macOS
  }
  let type : System
  let version: OperatingSystemVersion
  let buildNumber : String
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
  var isBuilt : Bool {
    false
  }
  
  enum CodingKeys : String, CodingKey {
    case id
    case restoreImage
    case operatingSystem
  }
  var configuration : MachineConfiguration?
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
  mutating func build (withInstaller installer: ImageInstaller)  throws {
    
      self.configuration = try installer.setupMachine(self)
    
  }
  
  func startInstallation (withInstaller installer: ImageInstaller) throws -> VirtualInstaller {
   
    guard let configuration = self.configuration else {
      throw NSError()
    }
      return try installer.beginInstaller(configuration: configuration)
    
  }
}
