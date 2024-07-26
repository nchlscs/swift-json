import Foundation

struct JSONSerializationDecoder {

  private let options: JSONSerialization.ReadingOptions
  private static let formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.maximumFractionDigits = .max
    f.minimumFractionDigits = .zero
    f.decimalSeparator = "."
    f.groupingSeparator = ""
    return f
  }()

  init(options: JSONSerialization.ReadingOptions = []) {
    self.options = options
  }

  func decodeNode(from data: Data) throws -> JSON.Node {
    let anyObject = try JSONSerialization.jsonObject(
      with: data,
      options: options
    )
    guard let jsonObject = anyObject as? NSObject else {
      throw DecodingError.dataCorrupted(.init(
        codingPath: [],
        debugDescription: "The given data was not valid JSON."
      ))
    }
    return try parse(jsonObject: jsonObject)
  }

  private func parse(jsonObject: NSObject) throws -> JSON.Node {
    switch jsonObject {
    case let dictionary as [String: NSObject]:
      return try .object(dictionary.mapValues(parse))
    case let array as [NSObject]:
      return try .array(array.map(parse))
    case let string as String:
      return .string(string)
    case let number as NSNumber:
      if number.isBoolean {
        return .boolean(number.boolValue)
      }
      return .number(Self.formatter.string(from: number)!)
    case _ as NSNull:
      return .null
    default:
      throw DecodingError.dataCorrupted(.init(
        codingPath: [],
        debugDescription: "The given data was not valid JSON."
      ))
    }
  }
}

private extension NSNumber {

  var isBoolean: Bool {
    CFGetTypeID(self) == CFBooleanGetTypeID()
  }
}
