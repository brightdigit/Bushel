//
//  RestoreImageLibraryItemFileView.swift
//  BshIll
//
//  Created by Leo Dion on 7/13/22.
//

import SwiftUI

struct RestoreImageLibraryItemFileView: View {
  @Binding var file : RestoreImageLibraryItemFile
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
          try BshIllApp.showNewDocumentWindow(ofType: MachineDocument.self)
        } catch {
          dump(error)
        }
      } label: {
        Image(systemName: "hammer.fill")
        Text("Build Machine")
      }
    }.padding()
  }
}

struct RestoreImageLibraryItemFileView_Previews: PreviewProvider {
    static var previews: some View {
      RestoreImageLibraryItemFileView(file: .constant(.init(name: "venturaBeta3", metadata: .Previews.venturaBeta3)))
    }
}
