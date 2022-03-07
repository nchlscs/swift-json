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
    private let key: String

    private func getValue<T>(
        from any: Any,
        as type: T.Type
    ) throws -> T {

        if T.self == [JSON].self,
           let array = any as? NSArray {
            return array.map { JSON(result: .success($0), key: key) } as! T
        }

        if let value = any as? T {
            return value
        }

        throw DecodingError.typeMismatch(key, any, T.self)
    }
}

public extension JSON {

    init(_ data: Data) throws {
        let value = try JSONSerialization.jsonObject(with: data)
        self.init(result: .success(value), key: "")
    }

    subscript(dynamicMember key: String) -> Self {

        guard let any = try? result.get() else {
            return .init(result: result, key: key)
        }

        guard let dict = any as? NSDictionary else {
            let error = DecodingError.typeMismatch(
                key, any, NSDictionary.self
            )
            return .init(result: .failure(error), key: key)
        }

        guard let value = dict[key] else {
            let error = DecodingError.keyNotFound(
                key, any, self.key
            )
            return .init(result: .failure(error), key: key)
        }

        return .init(result: .success(value), key: key)
    }

    subscript(_ key: String) -> JSON {
        self[dynamicMember: key]
    }

    subscript(_ index: Int) -> JSON {
        do {
            return try self([JSON].self)[index]
        } catch {
            return .init(result: .failure(error), key: key)
        }
    }

    func dynamicallyCall<T>(
        withArguments arguments: [T.Type]
    ) throws -> T {

        let any = try result.get()
        return try getValue(from: any, as: T.self)
    }

    func dynamicallyCall<T>(
        withArguments arguments: [T?.Type]
    ) throws -> T? {

        let any = try result.get()
        return try? getValue(from: any, as: T.self)
    }

    func dynamicallyCall(
        withArguments arguments: [Any] = []
    ) throws -> Any {

        try result.get()
    }
}

public extension JSON {

    enum DecodingError: Error, CustomStringConvertible {

        case keyNotFound(String, Any, String)
        case typeMismatch(String, Any, Any)

        public var description: String {
            switch self {
            case let .keyNotFound(key, value, root):
                return "No value associated with key '\(key)' in '\(root): \(value)'."
            case let .typeMismatch(key, value, expected):
                return "Expected to cast '\(value)' for key '\(key)' to '\(expected)', but found '\(type(of: value))' instead."
            }
        }
    }
}
