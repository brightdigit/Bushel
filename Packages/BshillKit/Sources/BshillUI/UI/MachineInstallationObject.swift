import Foundation
import BshillMachine

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
