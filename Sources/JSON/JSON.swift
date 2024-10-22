@dynamicMemberLookup
public struct JSON: Equatable, Sendable {
  var storage: Storage
}

public extension JSON {

  init(_ node: Node, configuration: Configuration = .defaultConfiguration) {
    let storage = Storage(result: .success(node), configuration: configuration)
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
    get {
      lookup(key: .init(stringValue: key))
    }
    set {
      update(value: newValue, for: .init(stringValue: key))
    }
  }

  subscript(dynamicMember key: String) -> any JSONConvertible {
    get {
      0
    }
    set {
      update(value: .init(newValue.jsonNode), for: .init(stringValue: key))
    }
  }

  subscript(key: String) -> JSON {
    get {
      lookup(key: .init(stringValue: key))
    }
    set {
      update(value: newValue, for: .init(stringValue: key))
    }
  }

  subscript(index: Int) -> JSON {
    get {
      lookup(key: .init(intValue: index))
    }
    set {
      update(value: newValue, for: .init(intValue: index))
    }
  }

  subscript(index: Int) -> (any JSONConvertible)? {
    get {
      nil
    }
    set {
      update(value: .init(newValue!.jsonNode), for: .init(intValue: index))
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

  static func string(_ json: JSON) -> String {
    switch json.storage.result {
    case let .success(node): node.description
    case let .failure(error): error.description
    }
  }
}

private extension JSON {

  func lookup(key: CodingKey) -> JSON {
    switch storage.result {
    case let .success(node):
      if case let .object(dictionary) = node,
        let node = dictionary[key.stringValue]
      {
        var storage = self.storage
        storage.result = .success(node)
        storage.codingPath += [key]
        return .init(storage: storage)
      }

      if case let .array(array) = node,
        let index = key.intValue,
        array.indices.contains(index)
      {
        var storage = self.storage
        storage.result = .success(array[index])
        storage.codingPath += [key]
        return .init(storage: storage)
      }

      var storage = self.storage
      storage.codingPath += [key]
      storage.result = .failure(
        .keyNotFound(codingPath: storage.codingPath.map(\.stringValue))
      )
      return .init(storage: storage)

    case let .failure(error):
      var storage = self.storage
      storage.result = .failure(error)
      storage.codingPath += [key]
      return .init(storage: storage)
    }
  }

  func unwrap<T: JSONDecodable>(as type: T.Type) throws -> T {
    if let value = try T(self) {
      return value
    }

    let underlyingType = try storage.result.get().underlyingType
    throw Error.typeMismatch(
      expected: String(describing: T.self),
      found: underlyingType,
      codingPath: storage.codingPath.map(\.stringValue)
    )
  }

  mutating func update(value: JSON, for key: CodingKey) {
    do {
      let value = try JSON.Node(value)
      switch try storage.result.get() {
      case var .object(object):
        object[key.stringValue] = value
        storage.result = .success(.object(object))
      case var .array(array):
        guard let index = key.intValue, index >= 0, index <= array.count else {
          fallthrough
        }
        if index < array.count {
          array[index] = value
        }
        else {
          array.append(value)
        }
        storage.result = .success(.array(array))
      default:
        let object = [key.stringValue: value]
        storage.result = .success(.object(object))
      }
    }
    catch {
      storage.result = .failure(.error(error))
    }
  }
}
