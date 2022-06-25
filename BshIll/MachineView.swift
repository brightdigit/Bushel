//
//  ContentView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

struct MachineRestoreImage : Hashable, Identifiable {
    let name : String
    let id : String
}
struct MachineView: View {
    @State var machineRestoreImage : MachineRestoreImage?
    @Binding var document: MachineDocument
    let restoreImageChoices : [MachineRestoreImage]
    var body: some View {
        VStack{
            
            Picker("Restore Image", selection: self.$machineRestoreImage) {
                ForEach(restoreImageChoices) { choice in
                    Text(choice.name)
                }
            }.padding()
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
