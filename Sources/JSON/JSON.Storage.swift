extension JSON {

  struct Storage: Sendable {
    var node: Node
    var codingPath: [CodingKey] = []
    var configuration: Configuration = .defaultConfiguration
  }
}

extension JSON.Storage: Equatable {

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.node == rhs.node && lhs.codingPath == rhs.codingPath
  }
}

extension JSON.Storage: CustomStringConvertible {

  var description: String {
    "\(node.description), codingPath: \(codingPath.description)"
  }
}
