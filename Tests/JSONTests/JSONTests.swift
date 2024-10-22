import Testing

@testable import JSON

@Test func testJSONDecoding() throws {
  let data = """
    {
      "string": "hello",
      "object": { "string": "hello" },
      "number": 1234,
    }
    """
  let json = try JSON(data.utf8)
  #expect(JSON(json) == json)
}

@Test func testObjectDecoding() throws {
  let data = """
    {
      "object1": {
        "string": "hello",
      },
      "object2": {
        "object3": {
          "array": ["hello", "world"]
        }
      }
    }
    """
  let json = try JSON(data.utf8)

  let object1: [String: String] = try json.object1
  #expect(object1 == ["string": "hello"])

  let array1: [String] = try json.object2.object3.array
  #expect(array1 == ["hello", "world"])

  let array2: [String] = try json["object2"]["object3"]["array"]
  #expect(array2 == ["hello", "world"])

  #expect {
    let _: [String: String] = try json.object2.object3.array
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["object2", "object3", "array"]))
    #expect(context.isDebugDescriptionEqual([String: String].self, "Array"))
    return true
  }

  #expect {
    let _: [String: Int] = try json.object1
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["object1"]))
    #expect(context.isDebugDescriptionEqual([String: Int].self, "Object"))
    return true
  }
}

@Test func testArrayDecoding() throws {
  let data = """
    {
      "array": ["hello", "world"]
    }
    """
  let json = try JSON(data.utf8)

  let string1: String = try json.array[0]
  #expect(string1 == "hello")
}

@Test func testStringDecoding() throws {
  let data = """
    {
      "string": "hello",
      "object": { "string": "hello" },
      "number": 1234,
    }
    """
  let json = try JSON(data.utf8)

  let string1: String = try json.string
  #expect(string1 == "hello")

  let string2: String = try json.object.string
  #expect(string2 == "hello")

  #expect {
    let _: String = try json.number
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["number"]))
    #expect(context.isDebugDescriptionEqual(String.self, "Number"))
    return true
  }
}

@Test func testBoolDecoding() throws {
  let data = """
    {
      "bool1": true,
      "bool2": false,
      "string1": "true",
      "string2": "false",
      "string3": "hello"
    }
    """
  let json = try JSON(data.utf8)

  #expect(try json.bool1 == true)
  #expect(try json.bool2 == false)
  #expect(try json.string1 == true)
  #expect(try json.string2 == false)

  #expect {
    try json.string3 == true
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["string3"]))
    #expect(context.isDebugDescriptionEqual(Bool.self, "String"))
    return true
  }
}

@Test func testNumberDecoding() throws {
  let data = """
    {
      "number1": 1234,
      "number2": 1234.56,
      "number3": -1234,
      "string1": "1234",
      "string2": "1234.56",
      "string3": "hello"
    }
    """
  let json = try JSON(data.utf8)

  let number1: Int = try json.number1
  #expect(number1 == 1234)

  let number2: Double = try json.number2
  #expect(number2 == 1234.56)

  let number3: Double = try json.number3
  #expect(number3 == -1234)

  let number4: Double = try json.string1
  #expect(number4 == 1234)

  let number5: Double = try json.string2
  #expect(number5 == 1234.56)

  #expect {
    let _: Int = try json.string3
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["string3"]))
    #expect(context.isDebugDescriptionEqual(Int.self, "String"))
    return true
  }
}

@Test func testOptionalDecoding() throws {
  let data = """
    {
      "string1": "hello",
      "string2": null,
    }
    """
  let json = try JSON(data.utf8)

  let string1: String? = try json.string1
  #expect(string1 == "hello")

  let string2: String? = try json.string2
  #expect(string2 == nil)
}

#if canImport(Foundation)
import Foundation

@Test func testDecimalDecoding() throws {
  let data = """
    {
      "number": 945.06,
      "string1": "945.06",
      "string2": "hello",
    }
    """
  let json = try JSON(data.utf8)

  #expect(try json.number == Decimal(string: "945.06")!)
  #expect(try json.string1 == Decimal(string: "945.06")!)

  #expect {
    let _: Decimal = try json.string2
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["string2"]))
    #expect(context.isDebugDescriptionEqual(Decimal.self, "String"))
    return true
  }
}

@Test func testURLDecoding() throws {
  let data = """
    {
      "string1": "http://localhost:3000",
      "string2": "",
    }
    """
  let json = try JSON(data.utf8)

  #expect(try json.string1 == URL(string: "http://localhost:3000")!)

  #expect {
    let _: URL = try json.string2
  } throws: { error in
    guard case let .typeMismatch(_, context) = error as? DecodingError else {
      return false
    }
    #expect(context.isCodingPathEqual(["string2"]))
    #expect(context.isDebugDescriptionEqual(URL.self, "String"))
    return true
  }
}
#endif

@Test func testJSONUnwrap() async throws {
  let data = """
    {
      "amount": 945.06,
      "currency": "USD",
    }
    """
  let json = try JSON(data.utf8)

  let balance = try JSON.unwrap(json, as: Balance.self)
  #expect(
    balance == Balance(amount: Decimal(string: "945.06")!, currency: .USD)
  )
}

private struct Balance: Equatable {
  let amount: Decimal
  let currency: Currency
}

extension Balance: JSONDecodable {

  init?(_ json: JSON) throws {
    try self.init(amount: json.amount, currency: json.currency)
  }
}

private enum Currency: String {
  case USD
}

extension Currency: JSONDecodable {

  init?(_ json: JSON) throws {
    try self.init(rawValue: JSON.unwrap(json, as: String.self))
  }
}

private extension DecodingError.Context {

  func isCodingPathEqual(
    _ codingPath: [String]
  ) -> Bool {
    self.codingPath.map(\.stringValue) == codingPath
  }

  func isDebugDescriptionEqual(
    _ expectedType: (some Any).Type,
    _ actualType: String
  ) -> Bool {
    debugDescription
      == "Expected \(expectedType) value but found \(actualType) instead."
  }
}
