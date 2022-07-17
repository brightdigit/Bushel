//
//  MachineDisplayView.swift
//  BshIll
//
//  Created by Leo Dion on 7/16/22.
//

import SwiftUI
import Virtualization

class MachineSession : ObservableObject {
  internal init(machine: Machine) {
    self.machine = machine
  }
  
  let machine : Machine
  
  func beginInstallation ()  throws {
    //let installer : VZMacOSRestoreImage  = try await machine.restoreImage?.installer() as! VZMacOSRestoreImage
    //let machine  = VZVirtualMachine(configuration: .init())
//    Task{
//      let installer = try await machine.restoreImage?.installer()
//      installer?.beginInstaller()
//    }
      //.beginInstaller()
    //let actualInstaller = VZMacOSInstaller(virtualMachine: machine, restoringFromImageAt: installer.url)
//    actualInstaller.progress.observe(\.fractionCompleted) { <#Progress#>, <#NSKeyValueObservedChange<Value>#> in
//      <#code#>
//    }
    //try await actualInstaller.install()
  }
  
  
  func startMachine () throws {
    Task{
      let installer = try await machine.restoreImage?.installer()
      
      //installer?.start()
    }
  }
}
struct MachineDisplayView: View {
  internal init( machine: Machine) {
    self._machineSession = .init(wrappedValue: .init(machine: machine))
  }
  
  @StateObject var machineSession: MachineSession
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MachineDisplayView_Previews: PreviewProvider {
    static var previews: some View {
      MachineDisplayView(machine: .init())
    }
}
