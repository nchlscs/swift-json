/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON {

  let result: Result<JSONValue, Error>
  let codingPath: [CodingKey]

  private func lookup(key: CodingKey) -> JSON {

    let value: JSONValue

    do {
      value = try result.get()
    } catch {
      return .init(result: .failure(error), codingPath: codingPath + [key])
    }

    switch value {
    case let .dictionary(dictionary):
      if let value = dictionary[key.stringValue] {
        return .init(result: .success(value), codingPath: codingPath + [key])
      }
    case let .array(array):
      if let index = key.intValue, array.indices.contains(index) {
        return .init(
          result: .success(array[index]),
          codingPath: codingPath + [key]
        )
      }
    default:
      break
    }

    let error = DecodingError.keyNotFound(key, .init(
      codingPath: codingPath,
      debugDescription: "No value associated with key '\(key)'."
    ))

    return .init(result: .failure(error), codingPath: codingPath + [key])
  }

  private func unwrap<T: JSONDecodable>(as type: T.Type) throws -> T {

    if let value = try T(self) {
      return value
    }

    let rawType = try result.get().rawValueType

    throw DecodingError.typeMismatch(T.self, .init(
      codingPath: codingPath,
      debugDescription: "Expected \(T.self) value but found \(rawType) instead."
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

  subscript(dynamicMember key: String) -> JSON {
    lookup(key: .init(stringValue: key))
  }

  subscript(key: String) -> JSON {
    lookup(key: .init(stringValue: key))
  }

  subscript(index: Int) -> JSON {
    lookup(key: .init(intValue: index))
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
