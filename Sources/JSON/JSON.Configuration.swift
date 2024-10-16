public extension JSON {

  struct Configuration: Sendable {

    public init() {}

    public var stringDecoder: @Sendable (JSON) throws -> String? = { json in
      switch JSON.Node(json) {
      case let .string(string): string
      default: nil
      }
    }

    public var numberDecoder: @Sendable (JSON) throws -> String? = { json in
      switch JSON.Node(json) {
      case let .string(string): string
      case let .number(string): string
      default: nil
      }
    }

    public var boolDecoder: @Sendable (JSON) throws -> Bool? = { json in
      switch JSON.Node(json) {
      case let .bool(bool): bool
      case let .string(string): Bool(string)
      default: nil
      }
    }
  }
}

public extension JSON.Configuration {
  @TaskLocal static var defaultConfiguration = Self()
}
