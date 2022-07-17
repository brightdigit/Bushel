
protocol WindowOpenHandle {
  var path : String { get }

}

extension WindowOpenHandle {
  var basic : BasicWindowOpenHandle.Type {
    return BasicWindowOpenHandle.self
  }
}

enum BasicWindowOpenHandle : String, CaseIterable, WindowOpenHandle {
    case machine
    case localImages
    case remoteSources
    case welcome
  
  var path: String {
    return self.rawValue
  }
}

struct MachineSessionWindowHandle : WindowOpenHandle {
  var path: String
  
  
}
