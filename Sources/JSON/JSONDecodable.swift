import Foundation

public protocol JSONDecodable {
  init?(_ json: JSON) throws
}

public extension JSONDecodable where Self: LosslessStringConvertible {

  init?(_ json: JSON) {
    switch json.node {
    case let .string(string), let .number(string):
      guard let result = Self(string) else {
        return nil
      }
      self = result
    default:
      return nil
    }
  }
}

extension JSON: JSONDecodable {

  public init(_ json: JSON) {
    self = json
  }
}

extension JSON.Node: JSONDecodable {

  public init(_ json: JSON) {
    self = json.node
  }
}

extension Int: JSONDecodable {}

extension Int8: JSONDecodable {}

extension Int16: JSONDecodable {}

extension Int32: JSONDecodable {}

extension Int64: JSONDecodable {}

extension UInt: JSONDecodable {}

extension UInt8: JSONDecodable {}

extension UInt16: JSONDecodable {}

extension UInt32: JSONDecodable {}

extension UInt64: JSONDecodable {}

extension Float: JSONDecodable {}

extension Double: JSONDecodable {}

extension String: JSONDecodable {

  public init?(_ json: JSON) {
    switch json.node {
    case let .string(string):
      self = string
    default:
      return nil
    }
  }
}

extension Bool: JSONDecodable {

  public init?(_ json: JSON) {
    switch json.node {
    case let .boolean(boolean):
      self = boolean
    case let .string(string):
      guard let boolean = Bool(string) else {
        return nil
      }
      self = boolean
    default:
      return nil
    }
  }
}

extension Decimal: JSONDecodable {

  public init?(_ json: JSON) {
    switch json.node {
    case let .string(string), let .number(string):
      guard let decimal = Decimal(string: string) else {
        return nil
      }
      self = decimal
    default:
      return nil
    }
  }
}

extension URL: JSONDecodable {

  public init?(_ json: JSON) {
    switch json.node {
    case let .string(string):
      guard let url = URL(string: string) else {
        return nil
      }
      self = url
    default:
      return nil
    }
  }
}

extension Optional: JSONDecodable where Wrapped: JSONDecodable {

  public init?(_ json: JSON) throws {
    switch json.node {
    case .null:
      self = .none
    default:
      guard let wrapped = try Wrapped(json) else {
        return nil
      }
      self = .some(wrapped)
    }
  }
}

extension Array: JSONDecodable where Element: JSONDecodable {

  public init?(_ json: JSON) throws {
    switch json.node {
    case let .array(array):
      var result = [Element]()
      result.reserveCapacity(array.count)
      for node in array {
        let json = JSON(node: node, codingPath: json.codingPath)
        guard let element = try Element(json) else {
          return nil
        }
        result.append(element)
      }
      self = result
    default:
      return nil
    }
  }
}

extension Dictionary: JSONDecodable where Key == String, Value: JSONDecodable {

  public init?(_ json: JSON) throws {
    switch json.node {
    case let .object(dictionary):
      var result = [String: Value](minimumCapacity: dictionary.count)
      for (key, node) in dictionary {
        let json = JSON(node: node, codingPath: json.codingPath)
        guard let element = try Value(json) else {
          return nil
        }
        result[key] = element
      }
      self = result
    default:
      return nil
    }
  }
}
