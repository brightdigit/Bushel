//
//  MachineSessionView.swift
//  BshIll
//
//  Created by Leo Dion on 7/18/22.
//

import SwiftUI

struct MachineSessionView: View {
  @Binding var document: MachineDocument
  let url : URL?
    var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).onAppear {
        document.machine.beginLoading()
      }
    }
}

//struct MachineSessionView_Previews: PreviewProvider {
//    static var previews: some View {
//        MachineSessionView()
//    }
//}
