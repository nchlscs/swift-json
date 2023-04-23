/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

public extension JSONDecodable where Self: Decodable {

  init?(_ json: JSON) throws {
    let value = try json.result.get()
    let data = try encoder.encode(value)
    self = try decoder.decode(Self.self, from: data)
  }
}
