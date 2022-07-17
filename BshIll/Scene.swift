import SwiftUI


extension Scene {
    func windowsHandle(_ handle: WindowOpenHandle) -> some Scene {
        self.handlesExternalEvents(matching: .init([handle.rawValue]))
    }
}
