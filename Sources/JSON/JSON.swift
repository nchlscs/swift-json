import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON: Equatable, Sendable {
  let node: Node
  let codingPath: [CodingKey]
}

public extension JSON {

  init(
    _ data: Data,
    configuration: JSONConfiguration = .global
  ) throws {
    let node = try configuration.decoder(data)
    self.init(node: node, codingPath: [])
  }

  init(
    _ string: String,
    configuration: JSONConfiguration = .global
  ) throws {
    let data = Data(string.utf8)
    try self.init(data, configuration: configuration)
  }

  init(_ node: Node) {
    self.init(node: node, codingPath: [])
  }

  init(_ jsonConvertible: some JSONConvertible) {
    self.init(node: jsonConvertible.jsonNode, codingPath: [])
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

  func dynamicallyCall<T: JSONDecodable>(
    withArguments arguments: [T.Type] = [T.self]
  ) throws -> T {
    try unwrap(as: T.self)
  }
}

extension JSON: CustomStringConvertible {

  public var description: String {
    node.description
  }
}

private extension JSON {

  func lookup(key: CodingKey) throws -> JSON {
    if case let .object(dictionary) = node,
       let node = dictionary[key.stringValue] {
      return .init(node: node, codingPath: codingPath + [key])
    }

    if case let .array(array) = node,
       let index = key.intValue,
       array.indices.contains(index) {
      return .init(
        node: array[index],
        codingPath: codingPath + [key]
      )
    }

    throw DecodingError.keyNotFound(key, .init(
      codingPath: codingPath,
      debugDescription: "No value associated with key '\(key)'."
    ))
  }

  func unwrap<T: JSONDecodable>(as type: T.Type) throws -> T {
    if let value = try T(self) {
      return value
    }

    let underlyingType = node.underlyingType

    throw DecodingError.typeMismatch(T.self, .init(
      codingPath: codingPath,
      debugDescription: "Expected \(T.self) value but found \(underlyingType) instead."
    ))
  }
}
