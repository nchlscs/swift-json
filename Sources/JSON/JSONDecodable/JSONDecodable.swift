/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

public protocol JSONDecodable {
  init?(_ json: JSON) throws
}

extension String: JSONDecodable {

  public init?(_ json: JSON) throws {
    let value = try json.result.get()
    switch value {
    case let .string(string):
      self = string
    default:
      return nil
    }
  }
}

extension Bool: JSONDecodable {

  public init?(_ json: JSON) throws {
    let value = try json.result.get()
    switch value {
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

  public init?(_ json: JSON) throws {
    let value = try json.result.get()
    switch value {
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
    let value = try json.result.get()
    switch value {
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
    let value = try json.result.get()
    switch value {
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
    let value = try json.result.get()
    switch value {
    case let .array(array):
      var result = [Element]()
      result.reserveCapacity(array.count)
      for value in array {
        let json = JSON(result: .success(value), codingPath: json.codingPath)
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

extension Dictionary: JSONDecodable
  where Key == String,
  Value: JSONDecodable {

  public init?(_ json: JSON) throws {
    let value = try json.result.get()
    switch value {
    case let .dictionary(dictionary):
      var result = [String: Value](minimumCapacity: dictionary.count)
      for (key, value) in dictionary {
        let json = JSON(result: .success(value), codingPath: json.codingPath)
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
