import Foundation

public extension JSON {

  enum Node: Equatable, Sendable {
    case object([String: Node])
    case array([Node])
    case string(String)
    case boolean(Bool)
    case number(String)
    case null
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
    case let .boolean(boolean):
      try container.encode(boolean)
    case let .number(number):
      if let int = Int(number) {
        try container.encode(int)
      } else if let double = Double(number) {
        try container.encode(double)
      } else {
        try container.encode(number)
      }
    case .null:
      try container.encodeNil()
    }
  }
}

extension JSON.Node: CustomStringConvertible {

  private static let descriptionEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
  }()

  public var description: String {
    do {
      let data = try Self.descriptionEncoder.encode(self)
      return String(decoding: data, as: UTF8.self)
    } catch {
      return "\(error)"
    }
  }
}

extension JSON.Node {

  var underlyingType: String {
    switch self {
    case .object: "Object"
    case .array: "Array"
    case .string: "String"
    case .boolean: "Boolean"
    case .number: "Number"
    case .null: "Null"
    }
  }
}
