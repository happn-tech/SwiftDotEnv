// swift-tools-version:5.0
import PackageDescription



let package = Package(
	name: "SwiftDotEnv",
	products: [
		.library(name: "DotEnv", targets: ["DotEnv"])
	],
	targets: [
		.target(name: "DotEnv", dependencies: []),
		.testTarget(name: "DotEnvTests", dependencies: ["DotEnv"])
	]
)
