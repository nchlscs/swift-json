/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON {

	private let result: Result<Value, Error>
	private let keys: [CodingKey]

	private func lookup(key: CodingKey) -> JSON {

		let value: Value

		do {
			value = try result.get()
		} catch {
			return .init(result: .failure(error), keys: keys + [key])
		}

		switch value {
		case let .dictionary(dictionary):
			if let value = dictionary[key.stringValue] {
				return .init(result: .success(value), keys: keys + [key])
			}
		case let .array(array):
			if let index = key.intValue, array.indices.contains(index) {
				return .init(result: .success(array[index]), keys: keys + [key])
			}
		default:
			break
		}

		let error = DecodingError.keyNotFound(key, .init(
			codingPath: keys,
			debugDescription: "No value associated with key '\(key)'."
		))

		return .init(result: .failure(error), keys: keys + [key])
	}

	private func unwrap<T>(as type: T.Type) throws -> T {

		let value = try result.get()

		if case let .array(array) = value,
		   let array = array
		   	.map({ JSON(result: .success($0), keys: keys) }) as? T {
			return array
		}

		if let value = value.rawValue as? T {
			return value
		}

		throw DecodingError.typeMismatch(T.self, .init(
			codingPath: keys,
			debugDescription: "Expected \(T.self) value but found \(Swift.type(of: value.rawValue)) instead."
		))
	}
}

public extension JSON {

	init(_ data: Data, options: JSONSerialization.ReadingOptions = []) throws {
		let object = try JSONSerialization.jsonObject(with: data, options: options)
		self.init(result: .success(.init(rawValue: object)), keys: [])
	}

	init(_ string: String, options: JSONSerialization.ReadingOptions = []) throws {
		let data = Data(string.utf8)
		try self.init(data, options: options)
	}

	subscript(dynamicMember key: String) -> JSON {
		lookup(key: .init(stringValue: key))
	}

	subscript(key: String) -> JSON {
		self[dynamicMember: key]
	}

	subscript(index: Int) -> JSON {
		lookup(key: .init(intValue: index))
	}

	func dynamicallyCall<T>(withArguments arguments: [T.Type]) throws -> T {
		try unwrap(as: T.self)
	}

	func dynamicallyCall<T>(withArguments arguments: [T?.Type]) throws -> T? {
		try? unwrap(as: T.self)
	}

	func dynamicallyCall(withArguments arguments: [Any] = []) throws -> Any {
		try result.get()
	}
}
