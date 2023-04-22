# Swift JSON

SwiftJSON is a syntactic sugar wrapper around [`JSONSerialization`](https://developer.apple.com/documentation/foundation/jsonserialization) that uses [`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md) and [`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/main/proposals/0216-dynamic-callable.md) features to unwrap values.

- [Swift JSON](#swift-json)
  - [Motivation](#motivation)
  - [Usage](#usage)
    - [Access and cast nested data](#access-and-cast-nested-data)
    - [Decode custom types with `JSONDecodable`](#decode-custom-types-with-JSONDecodable)
    - [More examples](#more-examples)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)

## Motivation

This is useful for accessing specific values from JSON data when you want to skip over unwanted boilerplate abstractions. For instance, we have the following fragment, and the longitude value is all we are interested in:

```swift
let data = """
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
  .data(using: .utf8)!
```

To achieve this with `JSONDecoder`, we need to populate the following structs:

```swift
import Foundation

struct Response: Decodable {
  let address: Address
}

struct Address: Decodable {
  let geo: Geo
}

struct Geo: Decodable {
  let longitude: Double
}

let longitude = try JSONDecoder()
  .decode(Response.self, from: data)
  .address
  .geo
  .longitude

// Prints 18.04
print(longitude)
```

With SwiftJSON it would be:

```swift
import JSON

let longitude = try JSON(data)
  .address
  .geo
  .longitude(Double.self)

// Prints 18.04
print(longitude)
```

## Usage

### Access and cast nested data

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

// Stockholm
let city = try JSON(response)
  .address
  .city(String.self)

// 18.04
let longitude = try JSON(response)
  .address
  .geo
  .longitude(Double.self)
```

### Decode custom types with `JSONDecodable`

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
      amount: json.amount(),
      currency: json.currency()
    )
  }
}

// Balance(amount: 1204.36, currency: "USD")
let balance = try JSON(response)
  .balances[0](Balance.self)

// [
//   Balance(amount: 1204.36, currency: "USD"),
//   Balance(amount: 945.06, currency: "EUR")
// ]
let balances = try JSON(response)
  .balances([Balance].self)
```

### More examples

[See tests](https://github.com/nchlscs/swift-json/blob/main/Tests/JSONTests/JSONTests.swift)

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/nchlscs/swift-json", from: "0.2.0")
```
