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
  case number(String)
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
    self = .number(String(value))
  }
}

extension JSONValue: ExpressibleByFloatLiteral {

  public init(floatLiteral value: FloatLiteralType) {
    self = .number(String(value))
  }
}

extension JSONValue: ExpressibleByNilLiteral {

  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSONValue: Encodable {

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
    case .number:
      return "Number"
    case .null:
      return "Null"
    }
  }
}
