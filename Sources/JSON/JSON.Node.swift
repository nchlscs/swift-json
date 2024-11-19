public extension JSON {

  enum Node: Hashable, Sendable, JSONDecodable {
    case object([String: Node])
    case array([Node])
    case string(String)
    case bool(Bool)
    case number(String)
    case null
  }
}

public extension JSON.Node {

  init(_ json: JSON) {
    self = json.storage.node
  }

  init(_ json: [JSON]) {
    self = .array(json.map(\.storage.node))
  }

  init(
    _ jsonConvertible: some JSONConvertible
  ) {
    self = jsonConvertible.jsonNode
  }
}

extension JSON.Node: Encodable {

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .object(dictionary):
      try container.encode(dictionary)
    case let .array(array):
      try container.encode(array)
    case let .string(string):
      try container.encode(string)
    case let .bool(bool):
      try container.encode(bool)
    case let .number(number):
      if let int = Int(number) {
        try container.encode(int)
      }
      else if let double = Double(number) {
        try container.encode(double)
      }
      else {
        try container.encode(number)
      }
    case .null:
      try container.encodeNil()
    }
  }
}

extension JSON.Node: CustomStringConvertible {

  public var description: String {
    Self.description(self, level: 0)
  }
}

extension JSON.Node {

  var underlyingType: String {
    switch self {
    case .object: "Object"
    case .array: "Array"
    case .string: "String"
    case .bool: "Boolean"
    case .number: "Number"
    case .null: "Null"
    }
  }
}

private extension JSON.Node {

  static func description(_ node: Self, level: Int) -> String {
    switch node {
    case let .object(value): objectDescription(value, level: level)
    case let .array(value): arrayDescription(value, level: level)
    case let .string(value): stringDescription(value)
    case let .bool(value): value.description
    case let .number(value): value
    case .null: "null"
    }
  }

  static func objectDescription(
    _ object: [String: Self],
    level: Int
  ) -> String {
    let description = object.sorted(by: { $0.key < $1.key })
      .map { key, value in
        let level = level + 1
        let key = stringDescription(key)
        let value = Self.description(value, level: level)
        return "\(Self.indentation(level: level))\(key): \(value)"
      }
      .joined(separator: ",\n")
    return """
      {
      \(description)
      \(Self.indentation(level: level))}
      """
  }

  static func arrayDescription(
    _ array: [Self],
    level: Int
  ) -> String {
    let description =
      array.map { value in
        let level = level + 1
        let value = Self.description(value, level: level)
        return "\(Self.indentation(level: level))\(value)"
      }
      .joined(separator: ",\n")
    return """
      [
      \(description)
      \(Self.indentation(level: level))]
      """
  }

  static func indentation(level: Int) -> String {
    String(repeating: "  ", count: level)
  }

  static func stringDescription(_ string: String) -> String {
    "\"" + string + "\""
  }
}
