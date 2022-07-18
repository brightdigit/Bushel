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
  
}
