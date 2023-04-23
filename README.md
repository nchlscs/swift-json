# Swift JSON

`swift-json` is a dynamic wrapper around JSON decoders that uses [`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md) and [`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/main/proposals/0216-dynamic-callable.md) features to access values from JSON data.

- [Swift JSON](#swift-json)
  - [Overview](#overview)
    - [More examples](#more-examples)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)

## Overview

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

With `swift-json` it would be:

```swift
import JSON

let longitude: Double = try JSON(data)
  .address
  .geo
  .longitude

// Prints 18.04
print(longitude)
```

### More examples

[See tests](https://github.com/nchlscs/swift-json/blob/main/Tests/JSONTests/JSONTests.swift)

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/nchlscs/swift-json", from: "0.3.0")
```
