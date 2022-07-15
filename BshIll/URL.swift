

extension URL {
    init (forHandle handle: WindowOpenHandle) {
        var components = Configuration.baseURLComponents
        components.path = handle.rawValue
        guard let url = components.url else {
            preconditionFailure()
        }
        self = url
    }
}
