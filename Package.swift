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
            from: "0.9.0"
        )
    ],
    targets: [
        .target(
            name: "FoundationKit",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "AuthenticationKit",
            dependencies: [
                "FoundationKit"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "ProductKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "OrderKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit",
                "ProductKit"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "ImageKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit",
                "ProductKit"
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
                "FoundationKit",
                "AuthenticationKit",
                "ProductKit",
                "OrderKit",
                "ImageKit",
                .product(name: "Harmonize", package: "Harmonize"),
            ]
        ),
    ]
)
