/**
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

@dynamicCallable
@dynamicMemberLookup
public struct JSON {

	private let result: Result<Any, Error>
	private let keys: [_CodingKey]

	private func lookup<T>(key: _CodingKey, as type: T.Type) -> JSON {

		let unwrapped: T

		do {
			unwrapped = try unwrap(as: type)
		} catch {
			return .init(result: .failure(error), keys: keys + [key])
		}

		if let dict = unwrapped as? NSDictionary,
		   let value = dict[key.stringValue] {
			return .init(result: .success(value), keys: keys + [key])
		}

		if let array = unwrapped as? [JSON],
		   let index = key.intValue,
		   array.indices ~= index {
			return .init(result: array[index].result, keys: keys + [key])
		}

		let error = Self.keyNotFoundError(key: key, keys: keys)
		return .init(result: .failure(error), keys: keys + [key])
	}

	private func unwrap<T>(as type: T.Type) throws -> T {

		let value = try result.get()

		if let array = value as? NSArray,
		   let array = array.map({ JSON(result: .success($0), keys: keys) }) as? T {
			return array
		}

		if let value = value as? T {
			return value
		}

		throw Self.typeMismatchError(value: value, keys: keys, expectedType: T.self)
	}
}

public extension JSON {

	init(_ data: Data, options: JSONSerialization.ReadingOptions = []) throws {
		let value = try JSONSerialization.jsonObject(with: data, options: options)
		self.init(result: .success(value), keys: [])
	}

	init(_ string: String, options: JSONSerialization.ReadingOptions = []) throws {
		let data = Data(string.utf8)
		try self.init(data, options: options)
	}

	subscript(dynamicMember key: String) -> JSON {
		lookup(key: .init(stringValue: key), as: NSDictionary.self)
	}

	subscript(key: String) -> JSON {
		self[dynamicMember: key]
	}

	subscript(index: Int) -> JSON {
		lookup(key: .init(intValue: index), as: [JSON].self)
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

private extension JSON {

	struct _CodingKey: CodingKey {

		let stringValue: String
		let intValue: Int?

		init(stringValue: String) {
			self.stringValue = stringValue
			self.intValue = nil
		}

		init(intValue: Int) {
			self.stringValue = "Index \(intValue)"
			self.intValue = intValue
		}

		var description: String {
			stringValue
		}

		var debugDescription: String {
			stringValue
		}
	}

	static func typeMismatchError<T>(
		value: Any,
		keys: [_CodingKey],
		expectedType: T.Type
	) -> DecodingError {

		.typeMismatch(T.self, .init(
			codingPath: keys,
			debugDescription: "Expected \(expectedType) value but found \(type(of: value)) instead."
		))
	}

	static func keyNotFoundError(
		key: _CodingKey,
		keys: [_CodingKey]
	) -> DecodingError {

		.keyNotFound(key, .init(
			codingPath: keys,
			debugDescription: "No value associated with key '\(key)'."
		))
	}
}
