/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

extension JSONDecoder: JSONValueDecoder {

  public func decodeJSONValue(from data: Data) throws -> JSONValue {
    try decode(JSONValue.self, from: data)
  }
}
