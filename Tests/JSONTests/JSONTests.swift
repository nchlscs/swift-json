/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import XCTest
@testable import JSON

final class JSONTests: XCTestCase {

  func testString() throws {
    let data = """
      {
      	"string": "Anna",
      	"dict": { "string": "1234" },
      	"int": 1234,
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.string(String.self), "Anna")
    XCTAssertEqual(try json.dict.string(String.self), "1234")
    XCTAssertEqual(try json["dict"]["string"](String.self), "1234")
    XCTAssertThrowsError(try json.int(String.self))
    XCTAssertThrowsError(try json.dict.value.string(String.self))
    XCTAssertThrowsError(try json.dict.string.value(String.self))
  }

  func testInt() throws {
    let data = """
      {
      	"int": 123,
      	"string": "123",
      	"negative": -123,
      	"double": 123.45
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.int(Int.self), 123)
    XCTAssertEqual(try json.string(Int.self), 123)
    XCTAssertEqual(try json.negative(Int.self), -123)
    XCTAssertThrowsError(try json.double(Int.self))
  }

  func testUInt() throws {
    let data = """
      {
      	"int": 123,
      	"string": "123",
      	"negative": -123,
      	"double": 123.45
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.int(UInt.self), 123)
    XCTAssertEqual(try json.string(UInt.self), 123)
    XCTAssertThrowsError(try json.negative(UInt.self))
    XCTAssertThrowsError(try json.double(UInt.self))
  }

  func testDouble() throws {
    let data = """
      {
      	"int": 1234,
      	"double": 1234.56,
      	"string": "1234.56"
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.int(Double.self), 1234.0)
    XCTAssertEqual(try json.double(Double.self), 1234.56)
    XCTAssertEqual(try json.string(Double.self), 1234.56)
  }

  func testBool() throws {
    let data = """
      {
      	"bool": true,
      	"string": "false",
      	"int": 1
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.bool(Bool.self), true)
    XCTAssertEqual(try json.string(Bool.self), false)
    XCTAssertThrowsError(try json.int(Bool.self))
  }

  func testDecimal() throws {
    let data = """
      {
          "int": 1234,
          "double": 1234.56,
          "string": "1234.56"
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json.int(Decimal.self), Decimal(string: "1234.0"))
    XCTAssertEqual(try json.double(Decimal.self), Decimal(string: "1234.56"))
    XCTAssertEqual(try json.string(Decimal.self), Decimal(string: "1234.56"))
  }

  func testURL() throws {
    let data = """
      {
      	"string": "https://example.com",
      	"dict": { "string": "^><?//" }
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(
      try json.string(URL.self),
      URL(string: "https://example.com")
    )
    XCTAssertThrowsError(try json.dict.string(URL.self))
  }

  func testArray() throws {
    let data = """
      [
      	[1, 2],
      	[3, 4]
      ]
      """
    let json = try JSON(data)

    XCTAssertEqual(try json([JSON].self).count, 2)
    XCTAssertEqual(try json[0]([Int].self), [1, 2])
    XCTAssertEqual(try json[1]([Int].self), [3, 4])
    XCTAssertThrowsError(try json[2]([Int].self))
  }

  func testDictionary() throws {
    let data = """
      {
      	"int": 1234,
      	"double": 1234.56,
      	"string": "1234.56"
      }
      """
    let json = try JSON(data)

    XCTAssertEqual(try json([String: JSON].self).count, 3)
    XCTAssertEqual(try json([String: JSON].self)["int"]!(Int.self), 1234)
  }

  func testOptional() throws {
    let data = """
      [
      	["1", "2", null],
      	[3, null, 4]
      ]
      """
    let json = try JSON(data)

    XCTAssertEqual(try json[0]([String?].self), ["1", "2", nil])
    XCTAssertEqual(try json[1]([Int?].self), [3, nil, 4])
  }

  func testExpressibleByJSON() throws {
    let data = """
      {
      	"balances": [
      		{
      			"amount": 1204.36,
      			"currency": "USD"
      		},
      		{
      			"amount": 945.06,
      			"currency": "EUR"
      		}
      	]
      }
      """

    XCTAssertEqual(
      try JSON(data).balances([Balance].self),
      [
        Balance(amount: Decimal(string: "1204.36")!, currency: "USD"),
        Balance(amount: Decimal(string: "945.06")!, currency: "EUR"),
      ]
    )
  }
}

private struct Balance: Equatable {
  let amount: Decimal
  let currency: String
}

extension Balance: ExpressibleByJSON {

  init?(_ json: JSON) throws {
    let amount = try json.amount(Decimal.self)
    let currency = try json.currency(String.self)
    self.init(amount: amount, currency: currency)
  }
}
