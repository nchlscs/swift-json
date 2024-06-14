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
    let json = JSON(data)

    XCTAssertEqual(try json.string, "Anna")
    XCTAssertEqual(try json.dict.string, "1234")
    XCTAssertEqual(try json["dict"]["string"], "1234")
    XCTAssertThrowsError(try json.int as String)
    XCTAssertThrowsError(try json.dict.value.string as String)
    XCTAssertThrowsError(try json.dict.string.value as String)
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
    let json = JSON(data)

    XCTAssertEqual(try json.int, 123)
    XCTAssertEqual(try json.string, 123)
    XCTAssertEqual(try json.negative, -123)
    XCTAssertThrowsError(try json.double as Int)
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
    let json = JSON(data)

    XCTAssertEqual(try json.int, 123)
    XCTAssertEqual(try json.string, 123)
    XCTAssertThrowsError(try json.negative as UInt)
    XCTAssertThrowsError(try json.double as UInt)
  }

  func testDouble() throws {
    let data = """
      {
      	"int": 1234,
      	"double": 1234.56,
      	"string": "1234.56"
      }
      """
    let json = JSON(data)

    XCTAssertEqual(try json.int, 1234.0)
    XCTAssertEqual(try json.double, 1234.56)
    XCTAssertEqual(try json.string, 1234.56)
  }

  func testBool() throws {
    let data = """
      {
      	"bool": true,
      	"string": "false",
      	"int": 1
      }
      """
    let json = JSON(data)

    XCTAssertEqual(try json.bool, true)
    XCTAssertEqual(try json.string, false)
    XCTAssertThrowsError(try json.int as Bool)
  }

  func testDecimal() throws {
    let data = """
      {
          "int": 1234,
          "double": 1234.56,
          "string": "1234.56"
      }
      """
    let json = JSON(data)

    XCTAssertEqual(try json.int, Decimal(string: "1234.0"))
    XCTAssertEqual(try json.double, Decimal(string: "1234.56"))
    XCTAssertEqual(try json.string, Decimal(string: "1234.56"))
  }

  func testURL() throws {
    let data = """
      {
      	"string": "https://example.com",
      	"dict": { "string": "https://{}" }
      }
      """
    let json = JSON(data)

    XCTAssertEqual(
      try json.string,
      URL(string: "https://example.com")
    )
    XCTAssertThrowsError(try json.dict.string as URL)
  }

  func testArray() throws {
    let data = """
      [
      	[1, 2],
      	[3, 4]
      ]
      """
    let json = JSON(data)

    XCTAssertEqual(try json([JSON].self).count, 2)
    XCTAssertEqual(try json[0], [1, 2])
    XCTAssertEqual(try json[1], [3, 4])
    XCTAssertThrowsError(try json[2] as [Int])
  }

  func testDictionary() throws {
    let data = """
      {
      	"int": 1234,
      	"double": 1234.56,
      	"string": "1234.56"
      }
      """
    let json = JSON(data)

    XCTAssertEqual(try json([String: JSON].self).count, 3)
    XCTAssertEqual(try json["int"], 1234)
  }

  func testOptional() throws {
    let data = """
      [
      	["1", "2", null],
      	[3, null, 4]
      ]
      """
    let json = JSON(data)

    XCTAssertEqual(try json[0], ["1", "2", nil])
    XCTAssertEqual(try json[1], [3, nil, 4])
  }

  func testJSONDecodable() throws {
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
      try JSON(data).balances,
      [
        Balance(amount: Decimal(string: "1204.36")!, currency: "USD"),
        Balance(amount: Decimal(string: "945.06")!, currency: "EUR")
      ]
    )
  }
}

private struct Balance: Equatable {
  let amount: Decimal
  let currency: String
}

extension Balance: JSONDecodable {

  init?(_ json: JSON) throws {
    try self.init(
      amount: json.amount,
      currency: json.currency
    )
  }
}
