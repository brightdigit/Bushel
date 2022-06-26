//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

enum OperatingSystemCodeName : Int, CaseIterable {
    case bigSur = 11
    case monterey = 12
    case ventura = 13
    
    
    init?(operatingSystemVersion : OperatingSystemVersion) {
        self.init(rawValue: operatingSystemVersion.majorVersion)
    }
    
    static let names : [OperatingSystemCodeName : String] = [
        .bigSur : "Big Sur",
            .monterey : "Monterey",
            .ventura : "Ventura"
        
        
    ]
    var name : String {
        guard let name = Self.names[self] else {
            preconditionFailure()
        }
        return name
    }
}
extension Image {
    init(operatingSystemVersion: OperatingSystemVersion) {
        let codeName = OperatingSystemCodeName(operatingSystemVersion: operatingSystemVersion)
        let imageName = codeName?.name
        self.init(imageName ?? "Big Sur")
    }
}

struct RestoreImageView: View {
    @Binding var document: RestoreImageDocument
    let byteFormatter : ByteCountFormatter = .init()
    var body: some View {
        switch document.loader.restoreImageResult {
        case .none:
            ProgressView()
        case .success(let image):
            VStack{
                Image(operatingSystemVersion: image.operatingSystemVersion).resizable().aspectRatio(1.0, contentMode: .fit).frame(height: 80.0).mask {
                    Circle()
                }.overlay {
                    Circle().stroke()
                }
                
                    Text("macOS \(OperatingSystemCodeName(operatingSystemVersion: image.operatingSystemVersion)?.name ?? "")").font(.title)
                    Text("Version \(image.operatingSystemVersion.description) (\(image.buildVersion.description))")
                
                VStack(alignment: .leading){
                    Button {
                        
                    } label: {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Download Image (\(byteFormatter.string(fromByteCount: Int64(image.contentLength))))")
                    }
                    ProgressView(value: 0.5) {
                        Text("Downloading").font(.caption)
                    } currentValueLabel: {
                        Text("8.9 GB / 16 GB")
                    }
                    
                    Button {
                        
                    } label: {
                        HStack{
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Import Image")
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "hammer.fill")
                        Text("Build Machine")
                    }
                }
                
            }.padding().fixedSize()
        default:
            EmptyView()
        }
    }
}

struct RestoreImageView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreImageView(document: .constant(RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: nil))))
        
        RestoreImageView(document: .constant(RestoreImageDocument(loader: MockRestoreImageLoader(restoreImageResult: .success(.init(isSupported: true, buildVersion: "12312SA", operatingSystemVersion: .init(majorVersion: 12, minorVersion: 0, patchVersion: 0), sha256: .init(hexidecialString: "1f9e921f77bbcb5cf78026389d6f7331cdd675bc081ffac77fc00405a7e822b3")!, contentLength: 16000000000, lastModified: Date(), installer: MockInstaller()))))))
    }
}
