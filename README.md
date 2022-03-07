# SwiftJSON

SwiftJSON — a tiny library for dynamic JSON data handling.

## Usage

Say we are dealing with the following JSON fragment, and the longitude value is all we are interested in.

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

To achieve this with "Codable", we have to define several boilerplate structs.

```swift
struct Response: Codable {
    
    let address: Address
    
    struct Address: Codable {
        
        let geo: Geo
        
        struct Geo: Codable {
            let longitude: Double
        }
    }
}

let longitude = try JSONDecoder()
    .decode(Response.self, from: data)
    .address
    .geo
    .longitude

print(longitude) // 18.04
```

With SwiftJSON it will be:

```swift
let longitude = try JSON(data)
    .address
    .geo
    .longitude(Double.self)

print(longitude) // 18.04
```

[More examples](https://github.com/nchlscs/swift-json/blob/main/Tests/SwiftJSONTests/SwiftJSONTests.swift)

## How it works

SwiftJSON uses `JSONSerialization` for converting JSON and `@dynamicMemberLookup` and `@dynamicCallable` features for unwrapping values.

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/nchlscs/swift-json", from: "1.0.0")
```

### Manually
Download and drag `Sources/SwiftJSON/SwiftJSON.swift` file into your project.
