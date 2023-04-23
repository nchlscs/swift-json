/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

public enum JSONValue: Equatable {
  case dictionary([String: JSONValue])
  case array([JSONValue])
  case string(String)
  case boolean(Bool)
  case integer(Int)
  case float(Double)
  case null
}

extension JSONValue: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (String, JSONValue)...) {
    self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
  }
}

extension JSONValue: ExpressibleByArrayLiteral {

  public init(arrayLiteral elements: JSONValue...) {
    self = .array(elements)
  }
}

extension JSONValue: ExpressibleByStringLiteral {

  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

extension JSONValue: ExpressibleByBooleanLiteral {

  public init(booleanLiteral value: BooleanLiteralType) {
    self = .boolean(value)
  }
}

extension JSONValue: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: IntegerLiteralType) {
    self = .integer(value)
  }
}

extension JSONValue: ExpressibleByFloatLiteral {

  public init(floatLiteral value: FloatLiteralType) {
    self = .float(value)
  }
}

extension JSONValue: ExpressibleByNilLiteral {

  public init(nilLiteral: ()) {
    self = .null
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
      throw DecodingError.dataCorrupted(.init(
        codingPath: [],
        debugDescription: "The given data was not valid JSON."
      ))
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

extension JSONValue {

  var underlyingType: String {
    switch self {
    case .dictionary:
      return "Dictionary"
    case .array:
      return "Array"
    case .string:
      return "String"
    case .boolean:
      return "Boolean"
    case .integer:
      return "Integer"
    case .float:
      return "Float"
    case .null:
      return "Null"
    }
  }
}
