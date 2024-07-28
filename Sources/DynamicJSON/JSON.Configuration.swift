import Foundation

public extension JSON {

  struct Configuration: Sendable {

    public init() {}

    public var stringDecoder: @Sendable (JSON) throws -> String? = { json in
      switch JSON.Node(json) {
      case let .string(string): string
      default: nil
      }
    }

    public var booleanDecoder: @Sendable (JSON) throws -> Bool? = { json in
      switch JSON.Node(json) {
      case let .boolean(boolean): boolean
      case let .string(string): Bool(string)
      default: nil
      }
    }

    public var decoder: @Sendable (Data) throws -> JSON.Node = { data in
      let decoder = JSONSerializationDecoder()
      return try decoder.decodeNode(from: data)
    }
  }
}

public extension JSON.Configuration {
  nonisolated(unsafe) static var `default` = Self()
}
