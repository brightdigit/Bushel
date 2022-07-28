

import Virtualization
extension ImageMetadata{
  init (sha256: SHA256, contentLength: Int, lastModified: Date, vzRestoreImage: VZMacOSRestoreImage) {
    self.init(isImageSupported: vzRestoreImage.isImageSupported, buildVersion: vzRestoreImage.buildVersion, operatingSystemVersion: vzRestoreImage.operatingSystemVersion, sha256: sha256, contentLength: contentLength, lastModified: lastModified, url: vzRestoreImage.url)
  }
}
