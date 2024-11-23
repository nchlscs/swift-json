 extension JSON {

  struct Storage: Sendable {
    var result: Result<Node, Error>
    var codingPath: [CodingKey] = []
    var configuration: Configuration = .defaultConfiguration
  }
}

extension JSON.Storage: Equatable {

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.node == rhs.node
  }
}

extension JSON.Storage: CustomStringConvertible {

  var description: String {
    switch result {
    case let .success(node):
      "\(node.description), codingPath: \(codingPath.description)"
    case let .failure(error):
      "\(error), codingPath: \(codingPath.description)"
    }
  }
}
