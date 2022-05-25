//
//  ContentView.swift
//  Bushel
//
//  Created by Leo Dion on 5/25/22.
//

import SwiftUI
import Virtualization

extension OperatingSystemVersion : CustomStringConvertible {
  public var description: String {
    [self.majorVersion, self.minorVersion, self.patchVersion].map(String.init).joined(separator: ".")
  }
}

struct ContentView: View {
  let session : URLSession = .shared
  @State var image: VZMacOSRestoreImage? = nil
  @State var destinationURL : URL? = nil
  @State var progress : Double?
    var body: some View {
      VStack{
        Button("Get Image") {
          VZMacOSRestoreImage.fetchLatestSupported { (result : Result<VZMacOSRestoreImage, Error>) in
            self.image = try? result.get()
          }
        }
        image.map{ image in
          VStack{
            Text(image.operatingSystemVersion.description)
            Text(image.buildVersion)
            Text(String(progress ?? 0))
          }
        }
        Button("Download Image") {
          guard let image = image else {
            return
          }
          let panel = NSSavePanel()
          panel.nameFieldLabel = "Save Restore Image as:"
          panel.nameFieldStringValue = "Bushel-Restore-\(image.operatingSystemVersion.description)-\(image.buildVersion).ipsw"
          panel.allowedContentTypes = [.init("com.apple.itunes.ipsw")!, .init("com.apple.iphone.ipsw")!]
          panel.isExtensionHidden = true
          panel.begin { response in
            
            guard let fileURL = panel.url, response == .OK else {
              return
            }
            DispatchQueue.main.async {
              self.destinationURL = fileURL
            }
//            let (asyncBytes, urlResponse) = try await self.session.bytes(from: image.url)
//            let length = urlResponse.expectedContentLength
//            let handle = try FileHandle(forWritingTo: fileURL)
//            var data = Data()
//            data.reserveCapacity(length)
//            for try await byte in asyncBytes {
//              handle.write(contentsOf: byte)
//            }
//            DispatchQueue.main.async {
//              self.destinationURL = fileURL
//              let downloadTask = session.downloadTask(with: image.url) { tempURL, _, error in
//                if let error = error {
//                  print(error)
//                  return
//                }
//
//                guard let tempURL = tempURL else {
//                  return
//                }
//
//                try? FileManager.default.moveItem(at: tempURL, to: fileURL)
//              }
//              self.downloadTask = downloadTask
//              downloadTask.resume()
//            }
          }
          
        }.disabled(image == nil).onChange(of: self.destinationURL) { url in
          guard let url = url, let image = image else {
            return
          }
          Task {
            FileManager.default.createFile(atPath: url.path, contents: nil)
            let handle = try FileHandle(forWritingTo: url)
            let (asyncBytes, urlResponse) = try await self.session.bytes(from: image.url)
            let length = UInt64(urlResponse.expectedContentLength)
                        for try await byte in asyncBytes {
                          
                          try handle.write(contentsOf: Data([byte]))
                          DispatchQueue.main.async {
                            self.progress = try? Double(handle.offset() * 10000 / length) / 100.0
                          }
                        }
          }
        }
      }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
