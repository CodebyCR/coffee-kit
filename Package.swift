// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("ImplicitSelfCapture"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("FullTypedThrows"),
    .unsafeFlags([
        "-Xfrontend", "-warn-long-function-bodies=30",
        "-Xfrontend", "-warn-long-expression-type-checking=14",
        "-Xfrontend", "-strict-concurrency=complete",
 //       "-warnings-as-errors"
    ]),
    .defaultIsolation(MainActor.self)
]

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
            swiftSettings: swiftSettings
        ),
        .target(
            name: "AuthenticationKit",
            dependencies: [
                "FoundationKit"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ProductKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "OrderKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit",
                "ProductKit"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ImageKit",
            dependencies: [
                "FoundationKit",
                "AuthenticationKit",
                "ProductKit"
            ],
            swiftSettings: swiftSettings
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
    ],
    swiftLanguageModes: [.v6]
)
