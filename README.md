# JSON

A small and customizable library that leverages Swift's dynamic features to provide an intuitive way to manipulate JSON data.

## Implemenation

`JSON` is an abstraction on `JSONParser`, [an internal parser from Swift's Foundation](https://github.com/swiftlang/swift-corelibs-foundation/blob/main/Sources/Foundation/JSONSerialization%2BParser.swift), which powers `JSONSerialization`. It utilies [`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md) and [`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/main/proposals/0216-dynamic-callable.md) features to access values from JSON data.

## Licensing

The project itself is under MIT Licence, but it includes the implementation of `JSONParser` from Swift's Foundation, which is licensed under the Apache License, Version 2.0.

## Examples

```swift
import JSON

let response = """
  {
    "address": {
      "city": "Stockholm",
      "geo": {
        "latitude": 59.2,
        "longitude": 18.04
      }
    }
  }
  """

let json = try JSON(response.utf8)
let city: String = try json.address.city
let longitude: Double = try json.address.geo.longitude

// Stockholm
print(city)

// 18.04
print(longitude)
```

```swift
import JSON

let response = """
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

struct Balance {
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

let json = try JSON(response.utf8)
let balances: [Balance] = try json.balances

// [Balance(amount: 1204.36, currency: "USD"), Balance(amount: 945.06, currency: "EUR")]
print(balances)
```
