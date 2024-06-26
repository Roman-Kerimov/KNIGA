// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KNIGA",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/Roman-Kerimov/LinguisticKit", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "KNIGA",
            dependencies: [.product(name: "LinguisticKit.static", package: "LinguisticKit")]
        ),
    ]
)
