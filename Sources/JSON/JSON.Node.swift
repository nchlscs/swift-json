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

  init(_ json: JSON) throws {
    self = try json.storage.result.get()
  }

  init(_ json: [JSON]) throws {
    self = try .array(json.map { try $0.storage.result.get() })
  }

  init(
    _ jsonConvertible: some JSONConvertible
  ) {
    self = jsonConvertible.jsonNode
  }

  var string: String {
    Self.description(self, level: 0, pretty: false)
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
    Self.description(self, level: 0, pretty: true)
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

  static func description(_ node: Self, level: Int, pretty: Bool) -> String {
    switch node {
    case let .object(value):
      objectDescription(value, level: level, pretty: pretty)
    case let .array(value):
      arrayDescription(value, level: level, pretty: pretty)
    case let .string(value): stringDescription(value)
    case let .bool(value): value.description
    case let .number(value): value
    case .null: "null"
    }
  }

  static func objectDescription(
    _ object: [String: Self],
    level: Int,
    pretty: Bool
  ) -> String {
    let separator = pretty ? "\n" : ""
    let description = object.sorted(by: { $0.key < $1.key })
      .map { key, value in
        let level = level + 1
        let key = Self.stringDescription(key)
        let value = Self.description(value, level: level, pretty: pretty)
        let indentation = pretty ? Self.indentation(level: level) : ""
        let space = pretty ? " " : ""
        return "\(indentation)\(key):\(space)\(value)"
      }
      .joined(separator: ",\(separator)")
    let indentation = pretty ? Self.indentation(level: level) : ""
    return ["{", description, indentation + "}"]
      .joined(separator: separator)
  }

  static func arrayDescription(
    _ array: [Self],
    level: Int,
    pretty: Bool
  ) -> String {
    let separator = pretty ? "\n" : ""
    let description =
      array.map { value in
        let level = level + 1
        let value = Self.description(value, level: level, pretty: pretty)
        let indentation = pretty ? Self.indentation(level: level) : ""
        return "\(indentation)\(value)"
      }
      .joined(separator: ",\(separator)")
    let indentation = pretty ? Self.indentation(level: level) : ""
    return ["[", description, indentation + "]"]
      .joined(separator: separator)
  }

  static func indentation(level: Int) -> String {
    String(repeating: "  ", count: level)
  }

  static func stringDescription(_ string: String) -> String {
    "\"" + string + "\""
  }
}
