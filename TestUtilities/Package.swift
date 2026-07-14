// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TestUtilities",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v12),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "TestUtilities",
            targets: ["TestUtilities"]
        ),
    ],
    dependencies: [
        .package(name: "OpenObserve", path: ".."),
    ],
    targets: [
        .target(
            name: "TestUtilities",
            dependencies: [
                .product(name: "OpenObserveCore", package: "OpenObserve"),
                .product(name: "OpenObserveRUM", package: "OpenObserve"),
                .product(name: "OpenObserveLogs",package: "OpenObserve"),
                .product(name: "OpenObserveTrace",package: "OpenObserve"),
                .product(name: "OpenObserveCrashReporting",package: "OpenObserve"),
                .product(name: "OpenObserveSessionReplay", package: "OpenObserve"),
                .product(name: "OpenObserveWebViewTracking",package: "OpenObserve")
            ],
            path: ".",
            sources: ["Sources"],
            swiftSettings: [.define("SPM_BUILD")]
        ),
    ]
)
