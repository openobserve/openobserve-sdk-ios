// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenObserveBenchmarks",
    platforms: [.iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "OpenObserveBenchmarks",
            targets: ["OpenObserveBenchmarks"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/open-telemetry/opentelemetry-swift-core", .upToNextMinor(from: "2.3.0"))
    ],
    targets: [
        .target(
            name: "OpenObserveBenchmarks",
            dependencies: [
                .product(name: "OpenTelemetryApi", package: "opentelemetry-swift-core"),
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift-core"),
            ]
        )
    ]
)
