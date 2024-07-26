import Foundation

public struct JSONConfiguration: Sendable {

  public var decoder: @Sendable (Data) throws -> JSON.Node = { data in
    let decoder = JSONSerializationDecoder()
    return try decoder.decodeNode(from: data)
  }
}

public extension JSONConfiguration {
  static var global = JSONConfiguration()
}
