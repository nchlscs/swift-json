// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "swift-json",
  platforms: [.macOS(.v11), .iOS(.v13)],
  products: [
    .library(name: "JSON", targets: ["JSON"])
  ],
  targets: [
    .target(name: "JSON", exclude: ["JSONParser/LICENSE.txt"]),
    .testTarget(name: "JSONTests", dependencies: ["JSON"]),
  ]
)
