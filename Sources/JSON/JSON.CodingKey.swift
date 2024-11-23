extension JSON {

  enum CodingKey: Swift.CodingKey, Equatable {
    case string(String)
    case int(Int)

    var stringValue: String {
      switch self {
      case let .string(value): value
      case let .int(value): String(value)
      }
    }

    var intValue: Int? {
      switch self {
      case .string: nil
      case let .int(value): value
      }
    }

    init(stringValue: String) {
      self = .string(stringValue)
    }

    init(intValue: Int) {
      self = .int(intValue)
    }

    var description: String {
      stringValue
    }

    var debugDescription: String {
      stringValue
    }
  }
}
