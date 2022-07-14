//
//  ContentView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

struct RestoreImageLibraryItemFolder : Codable {
  let relativePath : String
  let name : String
}

struct RestoreImageLibraryItemFile : Codable, Identifiable, Hashable {
  static func == (lhs: RestoreImageLibraryItemFile, rhs: RestoreImageLibraryItemFile) -> Bool {
    lhs.id == rhs.id
  }
  
  
  
  var id: Data {
    self.metadata.url.dataRepresentation
  }
  
  var name : String
  let metadata : ImageMetadata
}
//
//enum RestoreImageLibraryItem : Codable {
//  case folder(RestoreImageLibraryItemFolder)
//  case file(RestoreImageLibraryItemFile)
//}

struct RestoreImageLibrary : Codable {
  internal init(items: [RestoreImageLibraryItemFile] = .init()) {
    self.items = items
  }
  
  var items : [RestoreImageLibraryItemFile]
}



//struct FileItem: Hashable, Identifiable, CustomStringConvertible {
//    var id: Self { self }
//    var name: String
//    var children: [FileItem]? = nil
//    var description: String {
//        switch children {
//        case nil:
//            return "📄 \(name)"
//        case .some(let children):
//            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
//        }
//    }
//}
struct RestoreImageLibraryDocumentView: View {
  internal init(document: Binding<RestoreImageLibraryDocument>, selected: RestoreImageLibraryItemFile? = nil) {
    
    self._document = document
    self._selected = .init(wrappedValue: selected)
  }
  
  @Binding var document: RestoreImageLibraryDocument
  @State var selected : RestoreImageLibraryItemFile?
    var body: some View {
      NavigationView{
        VStack{
          List(self.document.library.items, selection: self.$selected) { item in
            Text("\(item.name)")
          }
          Spacer()
          Divider().opacity(0.75)
          HStack{
            Button {
              
            } label: {
              Image(systemName: "plus").padding(.leading, 8.0)
            }
            Divider().padding(.vertical, -6.0).opacity(0.75)
            Button {
              
            } label: {
              Image(systemName: "minus")
            }
            Divider().padding(.vertical, -6.0).opacity(0.75)
            Spacer()
          }.buttonStyle(.borderless).padding(.vertical, 2.0).fixedSize(horizontal: false, vertical: true).offset(x: 0.0, y: -2.0)
        }
          .frame(minWidth: 200, maxWidth: 500)
        Group{
          if let selected = selected {
            VStack{
              RestoreImageLibraryItemFileView(file: .init(get: {
                selected
              }, set: { file in
                let index = self.document.library.items.firstIndex { $0.id == file.id
                }
                if let index = index {
                  self.document.library.items[index] = file
                }
              }))
              Spacer()
            }
          } else {
            VStack{
              Text("test")
            }.padding()
          }
        }
          .layoutPriority(1)
      }
    }
}

struct RestoreImageLibraryDocumentView_Previews: PreviewProvider {
  static let data : [RestoreImageLibraryItemFile] = [
    .init(name: "Ventura Beta 3", metadata: .Previews.venturaBeta3),
    .init(name: "Montery 12.4", metadata: .Previews.monterey)
  ]
    static var previews: some View {
      RestoreImageLibraryDocumentView(document: .constant(RestoreImageLibraryDocument(library: .init(items: Self.data))), selected: .init(name: "Ventura Beta 3", metadata: .Previews.venturaBeta3))
    }
}
