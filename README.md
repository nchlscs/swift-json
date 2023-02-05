# Swift JSON

JSON is a syntactic sugar wrapper around [`JSONSerialization`](https://developer.apple.com/documentation/foundation/jsonserialization) that uses [`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md) and [`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/main/proposals/0216-dynamic-callable.md) features to unwrap values.

- [JSON](#json)
  - [Motivation](#motivation)
  - [Usage](#usage)
      - [Plain value](#plain-value)
      - [Nested value](#nested-value)
      - [Double value](#double-value)
      - [Decimal value](#decimal-value)
      - [Plain array value](#plain-array-value)
      - [Nested array value](#nested-array-value)
      - [Optional value](#optional-value)
      - [Index value](#index-value)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Manually](#manually)

## Motivation

This is useful for extracting specific values from JSON data when you don't want to define boilerplate one-off `Codable` abstractions. For instance, we are dealing with the following fragment and the longitude value is all we are interested in.

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

To achieve this with `Codable`, we have to populate the next structs:

```swift
struct Response: Codable {
  let address: Address
}

struct Address: Codable {
  let geo: Geo
}

struct Geo: Codable {
  let longitude: Double
}

let longitude = try JSONDecoder()
  .decode(Response.self, from: data)
  .address
  .geo
  .longitude

// 18.04
print(longitude)
```

With JSON it would be:

```swift
let longitude = try JSON(data)
  .address
  .geo
  .longitude(Double.self)

// 18.04
print(longitude)
```

## Usage

#### Plain value

```swift
let data = """
  {
    "name": "Anna"
  }
  """

// "Anna"
let value = try JSON(data).name(String.self)
```

#### Nested value

```swift
let data = """
  {
    "name": {
      "first_name": "Anna"
    }
  }
  """

// "Anna"
let value = try JSON(data)
  .name
  .first_name(String.self)
```

#### Double value

```swift
let data = """
  {
    "result": 3.14159
  }
  """

// 3.14159
let value = try JSON(data).result(Double.self)
```

#### Decimal value

```swift
let data = """
  {
    "balance": 20544.84
  }
  """

// 20544.84
let value = try JSON(data)
  .balance(NSNumber.self)
  .decimalValue
```

#### Plain array value

```swift
let data = """
  [
    100,
    101
  ]
  """

// [100, 101]
let value = try JSON(data)([Int].self)
```

#### Nested array value

```swift
let data = """
  {
    "balances": [
      {
        "amount": 1204.36,
        "currency": "USD"
      },
      {
        "amount": 945.06,
        "currency": "USD"
      }
    ]
  }
  """

// ["USD", "USD"]
let value = try JSON(data)
  .balances([JSON].self)
  .map(\.currency)
  .map { try $0(String.self) }
```

#### Optional value

```swift
let data = """
  [
    100,
    null,
    101
  ]
  """

// [100, nil, 101]
let value = try JSON(data)([Int?].self)
```

#### Index value

```swift
let data = """
  {
    "balances": [
      {
        "amount": 1204.36,
        "currency": "USD"
      },
      {
        "amount": 945.06,
        "currency": "USD"
      }
    ]
  }
  """

// "USD"
let value = try JSON(data)
  .balances[0]
  .currency(String.self)
```

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/nchlscs/swift-json", from: "0.1.0")
```

### Manually

Download and drag `Sources/JSON/JSON.swift` file into your project.
