/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

public struct JSONSerializationDecoder: JSONValueDecoder {

  public let options: JSONSerialization.ReadingOptions

  public init(options: JSONSerialization.ReadingOptions = []) {
    self.options = options
  }

  public func decodeJSONValue(from data: Data) throws -> JSONValue {
    let anyObject = try JSONSerialization.jsonObject(
      with: data,
      options: options
    )
    guard let jsonObject = anyObject as? NSObject else {
      throw DecodingError.dataCorrupted(.init(
        codingPath: [],
        debugDescription: "The given data was not valid JSON."
      ))
    }
    return try parse(jsonObject: jsonObject)
  }

  private func parse(jsonObject: NSObject) throws -> JSONValue {
    switch jsonObject {
    case let dictionary as [String: NSObject]:
      return try .dictionary(dictionary.mapValues(parse))
    case let array as [NSObject]:
      return try .array(array.map(parse))
    case let string as NSString:
      return .string(string as String)
    case let number as NSNumber:
      switch number.kind {
      case .boolean:
        return .boolean(number.boolValue)
      case .integer:
        return .integer(number.intValue)
      case .float:
        return .float(number.doubleValue)
      }
    case _ as NSNull:
      return .null
    default:
      throw DecodingError.dataCorrupted(.init(
        codingPath: [],
        debugDescription: "The given data was not valid JSON."
      ))
    }
  }
}

private extension NSNumber {

  enum Kind {
    case boolean
    case integer
    case float
  }

  var kind: Kind {
    if CFGetTypeID(self) == CFBooleanGetTypeID() {
      return .boolean
    }
    if CFNumberIsFloatType(self) {
      return .float
    }
    return .integer
  }
}
