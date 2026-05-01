// swift-tools-version: 6.2
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
            name: "FoundationKit",
            targets: ["FoundationKit"]
        ),
        .library(
            name: "AuthenticationKit",
            targets: ["AuthenticationKit"]
        ),
        .library(
            name: "ImageKit",
            targets: ["ImageKit"]
        ),
        .library(
            name: "OrderKit",
            targets: ["OrderKit"]
        ),
        .library(
            name: "ProductKit",
            targets: ["ProductKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/perrystreetsoftware/Harmonize.git",
            from: "0.1.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Coffee-Kit",
            dependencies: [
                "Authentication-Kit"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "Coffee-KitTests",
            dependencies: [
                "Coffee-Kit",
                .product(name: "Harmonize", package: "Harmonize"),
            ]
        ),
        
        .target(
            name: "Authentication-Kit",
            dependencies: [
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        )
    ]
)
