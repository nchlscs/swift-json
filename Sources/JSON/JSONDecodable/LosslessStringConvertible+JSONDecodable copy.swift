/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

private extension LosslessStringConvertible {

  @inline(__always)
  init?(commonInitFrom json: JSON) throws {
    let value = try json.result.get()
    switch value {
    case let .float(float):
      guard let result = Self(String(float)) else {
        return nil
      }
      self = result
    case let .integer(integer):
      guard let result = Self(String(integer)) else {
        return nil
      }
      self = result
    case let .string(string):
      guard let result = Self(string) else {
        return nil
      }
      self = result
    default:
      return nil
    }
  }
}

extension Int: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Int8: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Int16: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Int32: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Int64: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension UInt: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension UInt8: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension UInt16: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension UInt32: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension UInt64: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Float: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}

extension Double: JSONDecodable {

  public init?(_ json: JSON) throws {
    try self.init(commonInitFrom: json)
  }
}
