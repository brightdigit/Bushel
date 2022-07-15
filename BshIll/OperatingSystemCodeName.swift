import Foundation

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
