//
//  RestoreImageLibraryItemFileView.swift
//  BshIll
//
//  Created by Leo Dion on 7/13/22.
//

import SwiftUI
import BshillMachine

struct RestoreImageLibraryItemFileView: View {
  @Binding var file : RestoreImageLibraryItemFile
  @State var newMachine : MachineDocument?
  var body: some View {
    VStack(alignment: .leading){
      TextField("Name", text: self.$file.name).font(.largeTitle)
      HStack{
        Image(operatingSystemVersion: file.metadata.operatingSystemVersion).resizable().aspectRatio(1.0, contentMode: .fit).frame(height: 80.0).mask {
          Circle()
        }.overlay {
          Circle().stroke()
        }
        VStack(alignment: .leading){
          Text("macOS \(OperatingSystemCodeName(operatingSystemVersion: file.metadata.operatingSystemVersion)?.name ?? "")").font(.title)
          Text("Version \(file.metadata.operatingSystemVersion.description) (\(file.metadata.buildVersion.description))")
          Text(self.file.metadata.lastModified, style: .date)
        }
      }
      Button {
        do {
          self.newMachine = try MachineDocument(machine: .init(restoreImage: file.forMachine()))
        } catch {
          dump(error)
        }
      } label: {
        Image(systemName: "hammer.fill")
        Text("Build Machine")
      }
    }.padding().sheet(item: self.$newMachine) { machine in
      MachineSetupView(document: .init(get: {
        machine
      }, set: { document in
        self.newMachine = document
      }), url: nil, restoreImageChoices: [], onCompleted: {_ in
        self.newMachine = nil
      })
    }
  }
}

struct RestoreImageLibraryItemFileView_Previews: PreviewProvider {
    static var previews: some View {
      RestoreImageLibraryItemFileView(file: .constant(.init(name: "venturaBeta3", metadata: .Previews.venturaBeta3)))
    }
}
