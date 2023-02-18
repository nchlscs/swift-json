/*
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import XCTest
@testable import JSON

final class JSONTests: XCTestCase {

	func testPlainValue() throws {
		let data = """
				{
					"name": "Anna"
				}
			"""
		let value = try JSON(data).name(String.self)
		XCTAssertEqual(value, "Anna")
	}

	func testNestedValue() throws {
		let data = """
				{
					"name": {
						"first_name": "Anna"
					}
				}
			"""
		let value = try JSON(data).name.first_name(String.self)
		XCTAssertEqual(value, "Anna")
	}

	func testDoubleValue() throws {
		let data = """
				{
					"value": 3.14159
				}
			"""
		let value = try JSON(data).value(Double.self)
		XCTAssertEqual(value, 3.14159)
	}

	func testDecimalValue() throws {
		let data = """
				{
					"balance": 20544.84
				}
			"""
		let value = try JSON(data).balance(Decimal.self)
		XCTAssertEqual(value, Decimal(string: "20544.84"))
	}

	func testPlainArray() throws {
		let data = """
				[
					100,
					101
				]
			"""
		let value = try JSON(data)([Int].self)
		XCTAssertEqual(value, [100, 101])
	}

	func testNestedArray() throws {
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
		let jsons = try JSON(data).balances([JSON].self).map(\.currency)
		let value = try jsons.map { try $0(String.self) }
		XCTAssertEqual(value, ["USD", "EUR"])
	}

	func testOptionalValue() throws {
		let data = """
				[
					100,
					null,
					101
				]
			"""
		let value = try JSON(data)([Int?].self)
		XCTAssertEqual(value, [100, nil, 101])
	}

	func testArrayIndexValue() throws {
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
		let value = try JSON(data).balances[0].currency(String.self)
		XCTAssertEqual(value, "USD")
	}

	func testLiteralSyntax() throws {
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
		let value = try JSON(data)["balances"][0]["currency"](String.self)
		XCTAssertEqual(value, "USD")
	}
}
