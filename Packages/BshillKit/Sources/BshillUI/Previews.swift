import BshillMachine
extension RestoreImage {
  
  enum Previews {
    // ImageMetadata(isImageSupported: true, buildVersion: "true", operatingSystemVersion: OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0, sha256: SHA256(base64Encoded: "LbNHYPVKVKpwXUmqZInQ1Nr9gaYni4IKjelvzpl72LI=")!, contentLength: 0, lastModified: 2022-07-09 21:15:44 +0000, url: file:///var/folders/5d/8rl1m9ts5r96dxdh4rp_zx100000gn/T/com.brightdigit.BshIll/B6844821-A5C8-42B5-80C2-20F815FB920E.ipsw
    static func  usingMetadata(_ metadata: ImageMetadata) -> RestoreImage {
      .init(metadata: metadata, installer: {MockInstaller()})
    }
  }
}
