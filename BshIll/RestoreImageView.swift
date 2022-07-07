//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/28/22.
//

import SwiftUI
import UniformTypeIdentifiers

enum RestoreImageDownloadDestination {
  case library
  case ipswFile
}

enum DirectoryExists {
  case directoryExists
  case fileExists
  case notExists
}

extension DirectoryExists {
  init (fileExists: Bool, isDirectory: Bool) {
    if fileExists {
      self = isDirectory ? .directoryExists : .fileExists
    } else {
      self = .notExists
    }
  }
}

extension FileManager {
  func directoryExists(at url: URL) -> DirectoryExists {
    
    var isDirectory : ObjCBool = false
    let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    
    return .init(fileExists: fileExists, isDirectory: isDirectory.boolValue)
  }
}

extension RestoreImageDownloadDestination {
  func destinationURL(fromSavePanelURL url: URL) throws -> URL {
    guard self == .library else {
      return url
    }
    let libraryDirectoryExists = FileManager.default.directoryExists(at: url)
    guard libraryDirectoryExists != .fileExists  else {
      throw MissingError.needDefinition("Invalid Library")
    }
    
    let restoreImagesSubdirectoryURL = url.appendingPathComponent("Restore Images")
    
    let restoreImageSubdirectoryExists = FileManager.default.directoryExists(at: restoreImagesSubdirectoryURL)
    
    guard restoreImageSubdirectoryExists != .fileExists else {
      throw MissingError.needDefinition("Invalid Library")
    }
    
    if restoreImageSubdirectoryExists == .notExists {
      try FileManager.default.createDirectory(at: restoreImagesSubdirectoryURL, withIntermediateDirectories: true)
    }
    
    return restoreImagesSubdirectoryURL.appendingPathComponent(url.lastPathComponent)
  }
}

struct RestoreImageView: View {
  let byteFormatter : ByteCountFormatter = .init()
  let image : RestoreImage
  @StateObject var downloader = Downloader()
  @State var downloadDestination : RestoreImageDownloadDestination? = nil
  @State var askAboutDownload = false
    var body: some View {
      VStack{
        Image(operatingSystemVersion: image.metadata.operatingSystemVersion).resizable().aspectRatio(1.0, contentMode: .fit).frame(height: 80.0).mask {
          Circle()
        }.overlay {
          Circle().stroke()
        }
        
        Text("macOS \(OperatingSystemCodeName(operatingSystemVersion: image.metadata.operatingSystemVersion)?.name ?? "")").font(.title)
        Text("Version \(image.metadata.operatingSystemVersion.description) (\(image.metadata.buildVersion.description))")
        
        VStack(alignment: .leading){
          
          switch self.image.location {
          case .remote:
            
            if let prettyBytesTotal = downloader.prettyBytesTotal, let percentCompleted = downloader.percentCompleted {
                
                  Button {
                      downloader.cancel()
                      downloader.reset()
                      self.downloadDestination = nil
                  } label: {
                    Text("Cancel")
                  }
              ProgressView(value: percentCompleted) {
                  
                Text("Downloading").font(.caption)
              } currentValueLabel: {
                Text("\(downloader.prettyBytesWritten) / \(prettyBytesTotal)")
              }
            } else {
                
                  Button {
                    self.askAboutDownload = true
                  } label: {
                    Image(systemName: "icloud.and.arrow.down")
                    Text("Download Image (\(byteFormatter.string(fromByteCount: Int64(image.metadata.contentLength))))")
                  }
            }
          case .local:
            
            
            Button {
              
            } label: {
              HStack{
                Image(systemName: "square.and.arrow.down.fill")
                Text("Import Image")
              }
            }
          case .library:
            Button {
              
            } label: {
              Image(systemName: "hammer.fill")
              Text("Build Machine")
            }
          }

          
        }
        
      }.padding().alert("Download Restore Image", isPresented: self.$askAboutDownload, actions: {
        Button("Save to an IPSW File") {
          self.downloadDestination = .ipswFile
        }
        Button("Save to a Library") {
          self.downloadDestination = .library
        }
      }, message: {
        Text("Would you to download this into library or just save the file?")
      }).onChange(of: downloadDestination) { newValue in
        guard let downloadDestination = newValue else {
          return
        }
        
        let panel = NSSavePanel()
        switch downloadDestination {
        case .ipswFile:
          panel.nameFieldLabel = "Save Restore Image as:"
          panel.nameFieldStringValue = image.metadata.url.lastPathComponent
          panel.allowedContentTypes = UTType.ipswTypes
          panel.isExtensionHidden = true
        case .library:
          panel.nameFieldLabel = "Save to Library:"
          panel.allowedContentTypes = [UTType.restoreImageLibrary]
          panel.isExtensionHidden = true
          
          
        }
        panel.begin { response in
          
          guard let fileURL = panel.url, response == .OK else {
            return
          }
          
          let destinationURL : URL
          do {
            destinationURL = try downloadDestination.destinationURL(fromSavePanelURL: fileURL)
          } catch {
#warning("Something")
            return
          }
          downloader.begin(from: image.metadata.url, to: destinationURL)
          
          
        }
      }.onAppear {
        #if DEBUG
        debugPrint(self.image.metadata)
        #endif
      }
    }
}

struct RestoreImageView_Previews: PreviewProvider {
    static var previews: some View {
      RestoreImageView(image: .Previews.previewModel)
    }
}
