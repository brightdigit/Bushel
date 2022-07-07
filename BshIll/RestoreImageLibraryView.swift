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

struct RestoreImageLibraryItemFile : Codable {
  let metadata : ImageMetadata
}

enum RestoreImageLibraryItem : Codable {
  case folder(RestoreImageLibraryItemFolder)
  case file(RestoreImageLibraryItemFile)
}

struct RestoreImageLibrary : Codable {
  internal init(items: [RestoreImageLibraryItem] = .init()) {
    self.items = items
  }
  
  let items : [RestoreImageLibraryItem]
}

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
}
struct RestoreImageLibraryDocumentView: View {
  internal init(fileItems: [FileItem] = .init(), document: Binding<RestoreImageLibraryDocument>) {
    self.fileItems = fileItems
    self._document = document
  }
  
  let fileItems : [FileItem]
    @Binding var document: RestoreImageLibraryDocument
  @State var selected : FileItem?
    var body: some View {
      NavigationView{
        VStack{
          
          List(self.fileItems, children: \.children, selection: self.$selected) { item in
            Text("\(item.description)")
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
  static let data =
  FileItem(name: "users", children:
    [FileItem(name: "user1234", children:
      [FileItem(name: "Photos", children:
        [FileItem(name: "photo001.jpg"),
         FileItem(name: "photo002.jpg")]),
       FileItem(name: "Movies", children:
         [FileItem(name: "movie001.mp4")]),
          FileItem(name: "Documents", children: [])
      ]),
     FileItem(name: "newuser", children:
       [FileItem(name: "Documents", children: [])
       ])
    ])
    static var previews: some View {
      RestoreImageLibraryDocumentView(fileItems: [data], document: .constant(.init()))
    }
}
