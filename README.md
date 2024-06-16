# Swift JSON

`swift-json` is an experimental library that leverages the [`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md) and [`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/main/proposals/0216-dynamic-callable.md) dynamic features of Swift providing an intuitive way to access values from JSON data.

## Overview

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

let json = JSON(response)
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

let json = JSON(response)
let balances: [Balance] = try json.balances

// [Balance(amount: 1204.36, currency: "USD"), Balance(amount: 945.06, currency: "EUR")]
print(balances)
```
