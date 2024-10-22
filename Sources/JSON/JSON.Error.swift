public extension JSON {

  enum Error: Swift.Error, Equatable {
    case keyNotFound(codingPath: [String])
    case typeMismatch(expected: String, found: String, codingPath: [String])
    case error(Swift.Error)

    public static func == (lhs: JSON.Error, rhs: JSON.Error) -> Bool {
      lhs.description == rhs.description
    }
  }
}

extension JSON.Error: CustomStringConvertible {

  public var description: String {
    switch self {
    case let .keyNotFound(codingPath):
      let path = codingPath.joined(separator: ".")
      return "No value associated with key '\(path)'."
    case let .typeMismatch(expected, found, codingPath):
      // let path = codingPath.joined(separator: ".")
      return
        "Expected \(expected) value but found \(found) instead."
    case let .error(error):
      return error.localizedDescription
    }
  }
}
