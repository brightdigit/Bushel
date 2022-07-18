//
//  MachineView.swift
//  BshIll
//
//  Created by Leo Dion on 7/18/22.
//

import SwiftUI

struct MachineView: View {
  @Binding var document: MachineDocument
  let restoreImageChoices : [MachineRestoreImage]
    var body: some View {
      
        if !document.machine.isBuilt || document.machine.operatingSystem == nil {
          MachineSetupView(document: self.$document, restoreImageChoices: restoreImageChoices)
        } else {
          MachineSessionView(document: self.$document)
        }
    }
}

//struct MachineView_Previews: PreviewProvider {
//    static var previews: some View {
//        MachineView()
//    }
//}
