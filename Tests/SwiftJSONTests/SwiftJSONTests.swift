/**
 SwiftJSON
 Nikolay Davydov
 MIT license
 */

import XCTest
@testable import SwiftJSON

final class SwiftJSONTests: XCTestCase {

    let data = """
        {
            "age": 28,
            "cash": 115.99,
            "email": {
                "personal": "alex@mail.com"
            },
            "friends": [
                {
                    "name": "John",
                    "age": 32
                },
                {
                    "name": "Peter",
                    "age": null
                }
            ],
            "name": "Alex",
            "usernames": [
                "alex",
                "_alex"
            ]
        }
        """
        .data(using: .utf8)!

    func testJSON() throws {

        let json = try JSON(data)

        let string = try json.name(String.self)
        XCTAssertEqual(string, "Alex")

        let int = try json.age(Int.self)
        XCTAssertEqual(int, 28)

        let decimal = try json.cash(NSNumber.self).decimalValue
        XCTAssertEqual(decimal, Decimal(string: "115.99"))

        let nestedValue = try json.email.personal(String.self)
        XCTAssertEqual(nestedValue, "alex@mail.com")

        let arrayOfStrings = try json.usernames([String].self)
        XCTAssertEqual(arrayOfStrings, ["alex", "_alex"])

        let arrayOfJSONs = try json.friends([JSON].self)
        XCTAssertEqual(arrayOfJSONs.count, 2)

        let arrayOfOptionals = try arrayOfJSONs.map { try $0.age(Int?.self) }
        XCTAssertEqual(arrayOfOptionals, [32, nil])

        let elementOfArray = try json.friends[0].name(String.self)
        XCTAssertEqual(elementOfArray, "John")

        let altSyntax = try json["friends"][0]["name"](String.self)
        XCTAssertEqual(altSyntax, elementOfArray)
    }
}
