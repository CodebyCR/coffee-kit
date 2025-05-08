// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Coffee-Kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Coffee-Kit",
            targets: ["Coffee-Kit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/perrystreetsoftware/Harmonize.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Coffee-Kit",
            dependencies: [
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "Coffee-KitTests",
            dependencies: [
                "Coffee-Kit",
                .product(name: "Harmonize", package: "Harmonize"),
            ]
        ),
    ]
)
