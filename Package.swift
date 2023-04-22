// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "swift-json",
  products: [
    .library(
      name: "JSON",
      targets: ["JSON"]
    ),
  ],
  targets: [
    .target(
      name: "JSON",
      dependencies: []
    ),
    .testTarget(
      name: "JSONTests",
      dependencies: ["JSON"]
    ),
  ]
)
