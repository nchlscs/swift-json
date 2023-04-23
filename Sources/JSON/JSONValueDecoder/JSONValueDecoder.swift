/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

public protocol JSONValueDecoder {
  func decodeJSONValue(from data: Data) throws -> JSONValue
}
