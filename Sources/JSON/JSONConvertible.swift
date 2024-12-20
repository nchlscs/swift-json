public protocol JSONConvertible {
  var jsonNode: JSON.Node { get }
}

extension JSON.Node: JSONConvertible {
  public var jsonNode: JSON.Node { self }
}

extension Int: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Int8: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Int16: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Int32: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Int64: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension UInt: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension UInt8: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension UInt16: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension UInt32: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension UInt64: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Float: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension Double: JSONConvertible {
  public var jsonNode: JSON.Node { .number(String(self)) }
}

extension String: JSONConvertible {
  public var jsonNode: JSON.Node { .string(self) }
}

extension Bool: JSONConvertible {
  public var jsonNode: JSON.Node { .bool(self) }
}

extension Optional: JSONConvertible where Wrapped: JSONConvertible {
  public var jsonNode: JSON.Node { map(\.jsonNode) ?? .null }
}

extension [any JSONConvertible]: JSONConvertible {
  public var jsonNode: JSON.Node { .array(map(\.jsonNode)) }
}

extension [String: any JSONConvertible]: JSONConvertible {
  public var jsonNode: JSON.Node { .object(mapValues(\.jsonNode)) }
}

#if canImport(Foundation)
import Foundation

extension Decimal: JSONConvertible {
  public var jsonNode: JSON.Node { .number(description) }
}

extension URL: JSONConvertible {
  public var jsonNode: JSON.Node { .string(absoluteString) }
}
#endif
