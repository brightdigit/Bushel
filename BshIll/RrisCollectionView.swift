//
//  RrisCollectionView.swift
//  BshIll
//
//  Created by Leo Dion on 6/26/22.
//

import SwiftUI
import Virtualization
import Combine

struct Rris : Identifiable, Hashable {
    static func == (lhs: Rris, rhs: Rris) -> Bool {
        lhs.id == rhs.id
    }
    
    let id : String
    let title : String
    let fetch : () async throws -> [RestoreImage]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension VZMacOSRestoreImage {
  static func fetchLatestSupported () async throws -> VZMacOSRestoreImage {
    try await withCheckedThrowingContinuation({ continuation in
      self.fetchLatestSupported { result in
        continuation.resume(with: result)
      }
    })
  }
  
  static func loadFromURL(_ url: URL) async throws -> VZMacOSRestoreImage {
    try await withCheckedThrowingContinuation({ continuation in
      self.load(from: url, completionHandler: continuation.resume(with:))
    })
  }
}

extension Rris {
    static let apple : Rris = .init(id: "apple", title: "Apple") {
      let vzRestoreImage = try await VZMacOSRestoreImage.fetchLatestSupported()
      let virRestoreImage = try await VirtualizationMacOSRestoreImage(vzRestoreImage: vzRestoreImage)
      return [RestoreImage(imageContainer: virRestoreImage)]
//        try await withCheckedThrowingContinuation { continuation in
//            VZMacOSRestoreImage.fetchLatestSupported { result in
//              result.map(Virt)
//                continuation.resume(with: result.map(RestoreImage.init(imageMetadata:)).map{[$0]})
//
//            }
//        }
    }
}
extension Future where Failure == Error {
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
extension Future where Failure == Never {
    convenience init<SuccessType>(operation: @escaping () async throws -> SuccessType) where Output == Result<SuccessType, Error> {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(.success(output)))
                } catch {
                    promise(.success(.failure(error)))
                }
            }
        }
    }
}
class RrisCollectionObject : ObservableObject {
    let sources: [Rris] = [
        .apple
    ]
    @Published var selectedSource : String?
    @Published var imageListResult : Result<[RestoreImage], Error>?
    
    init() {
        self.$selectedSource.share().print().map{ _ in nil }.receive(on: DispatchQueue.main).assign(to: &$imageListResult)
        
        self.$imageListResult.combineLatest(self.$selectedSource).compactMap { imageListResult, source in
            imageListResult == nil ? self.sources.first(where: {$0.id == source}) : nil
        }.flatMap { source in
            Future(operation: source.fetch)
        }.map{$0 as Result<[RestoreImage], Error>?}.receive(on: DispatchQueue.main).assign(to: &$imageListResult)
    }
}
struct RrisCollectionView: View {
    
    init () {
    }
    @StateObject var selectedSourceObject  = RrisCollectionObject()
    @State var selectedImage : RestoreImage? = nil
    var body: some View {
        NavigationView {
            
                List{
                    ForEach(self.selectedSourceObject.sources) { source in
                        NavigationLink {
                            SourceImageCollectionView(source:source)
                        } label: {
                          Text(source.title)
                        }

                       
                    }
                }
        }
//            Group{
//                if case let .success(images) = self.selectedSourceObject.imageListResult {
//                    List(selection: self.$selectedImage){
//                        ForEach(images) { image in
//                            Text(image.operatingSystemVersion.description)
//                        }
//                    }
//                } else {
//                    Text("No Source Selected")
//                }
//            }.frame(width: 500)
//        }
    }
}

struct RrisCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RrisCollectionView()
    }
}
