/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import Foundation

extension JSON {

	enum Value {
		case dictionary([String: Value])
		case array([Value])
		case string(String)
		case bool(Bool)
		case int(Int)
		case double(Double)
		case null
		case unknown(Any)
	}
}

extension JSON.Value: RawRepresentable {

	var rawValue: Any {
		switch self {
		case let .dictionary(dictionary):
			return dictionary.mapValues(\.rawValue)
		case let .array(array):
			return array.map(\.rawValue)
		case let .string(string):
			return string
		case let .bool(bool):
			return bool
		case let .int(int):
			return int
		case let .double(double):
			return double
		case .null:
			return Any?.none as Any
		case let .unknown(rawValue):
			return rawValue
		}
	}

	init(rawValue: Any) {
		switch rawValue {
		case let dict as [String: Any]:
			self = .dictionary(dict.mapValues(Self.init))
		case let array as [Any]:
			self = .array(array.map(Self.init))
		case let string as String:
			self = .string(string)
		case let number as NSNumber:
			switch number.kind {
			case .bool:
				self = .bool(number.boolValue)
			case .int:
				self = .int(number.intValue)
			case .double:
				self = .double(number.doubleValue)
			}
		case _ as NSNull:
			self = .null
		default:
			assertionFailure("Unknown raw value type: \(type(of: rawValue)).")
			self = .unknown(rawValue)
		}
	}
}

private extension NSNumber {

	enum Kind {
		case bool
		case int
		case double
	}

	var kind: Kind {
		if CFGetTypeID(self) == CFBooleanGetTypeID() {
			return .bool
		}
		if CFNumberIsFloatType(self) {
			return .double
		}
		return .int
	}
}
