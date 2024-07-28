// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "swift-dynamic-json",
  products: [
    .library(
      name: "DynamicJSON",
      targets: ["DynamicJSON"]
    )
  ],
  targets: [
    .target(
      name: "DynamicJSON",
      dependencies: []
    ),
    .testTarget(
      name: "DynamicJSONTests",
      dependencies: ["DynamicJSON"]
    )
  ]
)
