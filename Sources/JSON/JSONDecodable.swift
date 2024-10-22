public protocol JSONDecodable {
  init?(_ json: JSON) throws
}

extension JSON: JSONDecodable {

  public init(_ json: JSON) {
    self = json
  }
}

extension String: JSONDecodable {

  public init?(_ json: JSON) throws {
    let decoder = json.storage.configuration.stringDecoder
    guard let string = try decoder(json) else {
      return nil
    }
    self = string
  }
}

extension Bool: JSONDecodable {

  public init?(_ json: JSON) throws {
    let decoder = json.storage.configuration.boolDecoder
    guard let bool = try decoder(json) else {
      return nil
    }
    self = bool
  }
}

public extension JSONDecodable
where Self: Numeric, Self: LosslessStringConvertible {

  init?(_ json: JSON) throws {
    let decoder = json.storage.configuration.numberDecoder
    guard let string = try decoder(json), let number = Self(string) else {
      return nil
    }
    self = number
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

extension Optional: JSONDecodable where Wrapped: JSONDecodable {

  public init?(_ json: JSON) throws {
    switch try JSON.Node(json) {
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
    switch try JSON.Node(json) {
    case let .array(array):
      var result = [Element]()
      result.reserveCapacity(array.count)
      for node in array {
        var storage = json.storage
        storage.result = .success(node)
        let json = JSON(storage: storage)
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
    switch try JSON.Node(json) {
    case let .object(dictionary):
      var result = [String: Value](minimumCapacity: dictionary.count)
      for (key, node) in dictionary {
        var storage = json.storage
        storage.result = .success(node)
        let json = JSON(storage: storage)
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

#if canImport(Foundation)
import Foundation

extension Decimal: JSONDecodable {

  public init?(_ json: JSON) throws {
    switch try JSON.Node(json) {
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

  public init?(_ json: JSON) throws {
    switch try JSON.Node(json) {
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
#endif
