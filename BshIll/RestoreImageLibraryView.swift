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
  
  let name : String
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
  
  let items : [RestoreImageLibraryItemFile]
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
  internal init(fileItems: [RestoreImageLibraryItemFile] = .init(), document: Binding<RestoreImageLibraryDocument>) {
    self.fileItems = fileItems
    self._document = document
  }
  
  let fileItems : [RestoreImageLibraryItemFile]
    @Binding var document: RestoreImageLibraryDocument
  @State var selected : RestoreImageLibraryItemFile?
    var body: some View {
      NavigationView{
        VStack{
          
          
          List(self.fileItems, selection: self.$selected) { item in
            Text("\(item.name)")
          }
//          OutlineGroup(fileItem, children: \.children) { item in
//            Text("\(item.description)")
//          }
//          List(categories, id: \.value, children: \.children) { tree in
//                      Text(tree.value).font(.subheadline)
//                  }.listStyle(SidebarListStyle())
          
          Spacer()
        }
          .frame(minWidth: 200, maxWidth: 500)
        VStack{
          Text("test")
        }.padding()
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
      RestoreImageLibraryDocumentView(fileItems: data, document: .constant(RestoreImageLibraryDocument()))
    }
}
