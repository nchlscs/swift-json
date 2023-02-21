/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

public protocol ExpressibleByJSON {
	init?(_ json: JSON) throws
}

extension String: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .string(string):
			self = string
		default:
			return nil
		}
	}
}

public extension LosslessStringConvertible where Self: ExpressibleByJSON {

	init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .double(double):
			guard let result = Self(String(double)) else {
				return nil
			}
			self = result
		case let .int(int):
			guard let result = Self(String(int)) else {
				return nil
			}
			self = result
		case let .string(string):
			guard let int = Self(string) else {
				return nil
			}
			self = int
		default:
			return nil
		}
	}
}

extension Int: ExpressibleByJSON {}
extension Int8: ExpressibleByJSON {}
extension Int16: ExpressibleByJSON {}
extension Int32: ExpressibleByJSON {}
extension Int64: ExpressibleByJSON {}
extension UInt: ExpressibleByJSON {}
extension UInt8: ExpressibleByJSON {}
extension UInt16: ExpressibleByJSON {}
extension UInt32: ExpressibleByJSON {}
extension UInt64: ExpressibleByJSON {}
extension Float: ExpressibleByJSON {}
extension Double: ExpressibleByJSON {}

extension Bool: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .bool(bool):
			self = bool
		case let .string(string):
			guard let bool = Bool(string) else {
				return nil
			}
			self = bool
		default:
			return nil
		}
	}
}

extension Decimal: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .string(string):
			guard let decimal = Decimal(string: string) else {
				return nil
			}
			self = decimal
		case let .int(int):
			guard let decimal = Decimal(string: String(int)) else {
				return nil
			}
			self = decimal
		case let .double(double):
			guard let decimal = Decimal(string: String(double)) else {
				return nil
			}
			self = decimal
		default:
			return nil
		}
	}
}

extension URL: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .string(string):
			guard let url = URL(string: string) else {
				return nil
			}
			self = url
		default:
			return nil
		}
	}
}

extension Optional: ExpressibleByJSON where Wrapped: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case .null:
			self = .none
		default:
			guard let wrapped = try Wrapped(json) else {
				return nil
			}
			self = .some(wrapped)
		}
	}
}

extension JSON: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		self = json
	}
}

extension Array: ExpressibleByJSON where Element: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .array(array):
			var result = [Element]()
			for value in array {
				let json = JSON(result: .success(value), codingPath: json.codingPath)
				guard let element = try Element(json) else {
					return nil
				}
				result.append(element)
			}
			self = result
		default:
			return nil
		}
	}
}

extension Dictionary: ExpressibleByJSON
	where Key == String,
	Value: ExpressibleByJSON {

	public init?(_ json: JSON) throws {
		let value = try json.result.get()
		switch value {
		case let .dictionary(dictionary):
			var result = [String: Value](minimumCapacity: dictionary.count)
			for (key, value) in dictionary {
				let json = JSON(result: .success(value), codingPath: json.codingPath)
				guard let element = try Value(json) else {
					return nil
				}
				result[key] = element
			}
			self = result
		default:
			return nil
		}
	}
}
