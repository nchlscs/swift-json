/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON {

	let result: Result<Value, Error>
	let codingPath: [CodingKey]

	private func lookup(key: CodingKey) -> JSON {

		let value: Value

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
				return .init(result: .success(array[index]), codingPath: codingPath + [key])
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

	private func unwrap<T: ExpressibleByJSON>(as type: T.Type) throws -> T {

		if let value = try T(self) {
			return value
		}

		let value = try result.get().rawValue

		throw DecodingError.typeMismatch(T.self, .init(
			codingPath: codingPath,
			debugDescription: "Expected \(T.self) value but found \(Swift.type(of: value)) instead."
		))
	}
}

public extension JSON {

	init(_ data: Data, options: JSONSerialization.ReadingOptions = []) throws {
		let object = try JSONSerialization.jsonObject(with: data, options: options)
		self.init(result: .success(.init(rawValue: object)), codingPath: [])
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

	func dynamicallyCall<T: ExpressibleByJSON>(
		withArguments arguments: [T.Type]
	) throws -> T {
		try unwrap(as: T.self)
	}
}
