/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

public enum JSONValue {
  case dictionary([String: JSONValue])
  case array([JSONValue])
  case string(String)
  case boolean(Bool)
  case integer(Int)
  case float(Double)
  case null
}

extension JSONValue {

  var rawValueType: Any.Type {
    switch self {
    case .dictionary:
      return [String: Any].self
    case .array:
      return [Any].self
    case .string:
      return String.self
    case .boolean:
      return Bool.self
    case .integer:
      return Int.self
    case .float:
      return Double.self
    case .null:
      return Any?.self
    }
  }
}

extension JSONValue: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let dictionary = try? container.decode([String: Self].self) {
      self = .dictionary(dictionary)
    } else if let array = try? container.decode([Self].self) {
      self = .array(array)
    } else if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let boolean = try? container.decode(Bool.self) {
      self = .boolean(boolean)
    } else if let integer = try? container.decode(Int.self) {
      self = .integer(integer)
    } else if let float = try? container.decode(Double.self) {
      self = .float(float)
    } else if container.decodeNil() {
      self = .null
    } else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .dictionary(dictionary):
      try container.encode(dictionary)
    case let .array(array):
      try container.encode(array)
    case let .string(string):
      try container.encode(string)
    case let .boolean(boolean):
      try container.encode(boolean)
    case let .integer(integer):
      try container.encode(integer)
    case let .float(float):
      try container.encode(float)
    case .null:
      try container.encodeNil()
    }
  }
}
