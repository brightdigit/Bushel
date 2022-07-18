//
//  ContentView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

enum MachinePreparationState : Int, Identifiable {
  var id: RawValue {
    self.rawValue
  }
  
  case building
  case installing
}

struct MachineView: View {
  
  @State var machinePreparing : MachinePreparationState? = nil
  @State var machineRestoreImage : MachineRestoreImage?
  @Binding var document: MachineDocument
  @StateObject var installationObject = MachineInstallationObject()
  let restoreImageChoices : [MachineRestoreImage]
  
  func start () {
    //document.machine.start()
  }
  
  var body: some View {
    VStack{
      if document.machine.operatingSystem == nil {
        Picker("Restore Image", selection: self.$machineRestoreImage) {
          ForEach(restoreImageChoices) { choice in
            Text(choice.name)
          }
        }.padding()
      }
      Button {
        if !document.machine.isBuilt {
          self.machinePreparing = .building
        } else if document.machine.operatingSystem == nil {
          self.machinePreparing = .installing
        } else {
        }
        
      } label: {
        Text("Start")
      }
      
    }.onReceive(self.installationObject.$isCompletedWithError, perform: { completed in
      guard let completed = completed  else {
        return
      }
      do {
        try completed.get()
      } catch {
        dump(error)
        return
      }
      self.start()
    })
    .onAppear{
      self.machineRestoreImage = document.machine.restoreImage.map(MachineRestoreImage.init(file:))
    }.sheet(item: self.$machinePreparing) { state in
      VStack{
        HStack{
          Image(systemName: state == .building ? "play.fill" : "checkmark.circle.fill")
          Text("Building Machine...")
        }
        HStack{
          Image(systemName: state == .installing ? "play.fill" : "checkmark.circle.fill")
          ProgressView(value: self.installationObject.progressValue) {
            Text("Installing Operating System...")
          }
        }
        
      }.task {
        guard let installer = try? await document.machine.createInstaller() else {
          return
        }
        let vInstaller : VirtualInstaller
        do {
          let configuration = try document.machine.build(withInstaller: installer)
          await MainActor.run {
            self.machinePreparing = .installing
            self.document.machine.setConfiguration(configuration)
          }
          vInstaller = try document.machine.startInstallation(with: installer, using: configuration)
        } catch {
          return
        }
        installationObject.setupInstaller(vInstaller)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MachineView(document: .constant(MachineDocument()), restoreImageChoices: [
      MachineRestoreImage(name: "name", id: "name"),
      
      MachineRestoreImage(name: "test", id: "test"),
      MachineRestoreImage(name: "hello", id: "hello")
    ])
  }
}
