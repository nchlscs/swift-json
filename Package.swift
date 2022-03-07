// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
	name: "SwiftJSON",
	products: [
		.library(
			name: "SwiftJSON",
			targets: ["SwiftJSON"]
		)
	],
	targets: [
		.target(
			name: "SwiftJSON",
			dependencies: []
		),
		.testTarget(
			name: "SwiftJSONTests",
			dependencies: ["SwiftJSON"]
		)
	]
)
