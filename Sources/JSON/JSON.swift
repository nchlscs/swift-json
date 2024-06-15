/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON: Sendable {

  let result: Result<JSONValue, Error>
  let codingPath: [CodingKey]

  private func lookup(key: CodingKey) throws -> JSON {

    let value = try result.get()

    if case let .object(dictionary) = value,
       let value = dictionary[key.stringValue] {
      return .init(result: .success(value), codingPath: codingPath + [key])
    }

    if case let .array(array) = value,
       let index = key.intValue,
       array.indices.contains(index) {
      return .init(
        result: .success(array[index]),
        codingPath: codingPath + [key]
      )
    }

    throw DecodingError.keyNotFound(key, .init(
      codingPath: codingPath,
      debugDescription: "No value associated with key '\(key)'."
    ))
  }

  private func unwrap<T: JSONDecodable>(as type: T.Type) throws -> T {

    if let value = try T(self) {
      return value
    }

    let underlyingType = try result.get().underlyingType

    throw DecodingError.typeMismatch(T.self, .init(
      codingPath: codingPath,
      debugDescription: "Expected \(T.self) value but found \(underlyingType) instead."
    ))
  }
}

public extension JSON {

  init(
    _ data: Data,
    using decoder: some JSONValueDecoder = JSONSerializationDecoder()
  ) {
    let result = Result<JSONValue, Error> {
      try decoder.decodeJSONValue(from: data)
    }
    self.init(result: result, codingPath: [])
  }

  init(
    _ string: String,
    using decoder: some JSONValueDecoder = JSONSerializationDecoder()
  ) {
    let data = Data(string.utf8)
    self.init(data, using: decoder)
  }

  init(_ jsonValue: JSONValue) {
    self.init(result: .success(jsonValue), codingPath: [])
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
