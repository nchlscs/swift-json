/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

extension JSON: JSONDecodable {

  public init(_ json: JSON) {
    self = json
  }
}

extension JSONValue: JSONDecodable {

  public init(_ json: JSON) throws {
    self = try json.result.get()
  }
}
