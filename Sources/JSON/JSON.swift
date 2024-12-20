@dynamicMemberLookup
public struct JSON: Equatable, Sendable {
  var storage: Storage
}

public extension JSON {

  init(_ node: Node, configuration: Configuration = .defaultConfiguration) {
    let storage = Storage(node: node, configuration: configuration)
    self.init(storage: storage)
  }

  init(
    _ data: some Collection<UInt8>,
    configuration: Configuration = .defaultConfiguration
  ) throws {
    var parser = JSONParser(bytes: Array(data))
    let node = try parser.parse()
    self.init(node, configuration: configuration)
  }

  init(
    _ jsonConvertible: some JSONConvertible,
    configuration: Configuration = .defaultConfiguration
  ) {
    self.init(jsonConvertible.jsonNode, configuration: configuration)
  }

  subscript(dynamicMember key: String) -> JSON {
    get throws {
      try lookup(key: .init(stringValue: key))
    }
  }

  subscript(key: String) -> JSON {
    get throws {
      try lookup(key: .init(stringValue: key))
    }
  }

  subscript(index: Int) -> JSON {
    get throws {
      try lookup(key: .init(intValue: index))
    }
  }

  subscript<T: JSONDecodable>(dynamicMember key: String) -> T {
    get throws {
      try lookup(key: .init(stringValue: key)).unwrap(as: T.self)
    }
  }

  subscript<T: JSONDecodable>(key: String) -> T {
    get throws {
      try lookup(key: .init(stringValue: key)).unwrap(as: T.self)
    }
  }

  subscript<T: JSONDecodable>(index: Int) -> T {
    get throws {
      try lookup(key: .init(intValue: index)).unwrap(as: T.self)
    }
  }

  static func unwrap<T: JSONDecodable>(
    _ json: JSON,
    as type: T.Type
  ) throws -> T {
    try json.unwrap(as: type)
  }

  static func withMutableStorage(
    of json: inout JSON,
    body: (inout Setter) throws -> Void
  ) rethrows {
    var setter = Setter(json: json)
    try body(&setter)
    json.storage.node = setter.json.storage.node
  }

  static func map<T>(
    _ json: JSON,
    transform: (JSON) throws -> T
  ) throws -> [T] {
    try json.unwrap(as: [JSON].self).map(transform)
  }

  static func compactMap<T>(
    _ json: JSON,
    transform: (JSON) throws -> T?
  ) throws -> [T] {
    try json.unwrap(as: [JSON].self).compactMap(transform)
  }

  static func filter(
    _ json: JSON,
    isIncluded: (JSON) throws -> Bool
  ) throws -> [JSON] {
    try json.unwrap(as: [JSON].self).filter(isIncluded)
  }

  static func forEach(
    _ json: JSON,
    body: (JSON) throws -> Void
  ) throws {
    try json.unwrap(as: [JSON].self).forEach(body)
  }
}

private extension JSON {

  func lookup(key: CodingKey) throws -> JSON {
    if case let .object(dictionary) = storage.node,
      let node = dictionary[key.stringValue]
    {
      var storage = self.storage
      storage.node = node
      storage.codingPath += [key]
      return .init(storage: storage)
    }

    if case let .array(array) = storage.node,
      let index = key.intValue,
      array.indices.contains(index)
    {
      var storage = self.storage
      storage.node = array[index]
      storage.codingPath += [key]
      return .init(storage: storage)
    }

    throw DecodingError.keyNotFound(
      key,
      .init(
        codingPath: storage.codingPath,
        debugDescription: "No value associated with key '\(key)'."
      )
    )
  }

  func unwrap<T: JSONDecodable>(as type: T.Type) throws -> T {
    if let value = try T(self) {
      return value
    }

    let underlyingType = storage.node.underlyingType

    throw DecodingError.typeMismatch(
      T.self,
      .init(
        codingPath: storage.codingPath,
        debugDescription:
          "Expected \(T.self) value but found \(underlyingType) instead."
      )
    )
  }
}
