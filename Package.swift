// swift-tools-version: 5.9

import PackageDescription
import Foundation

let internalSwiftSettings: [SwiftSetting] = ProcessInfo.processInfo.environment["DD_BENCHMARK"] != nil ?
    [.define("DD_BENCHMARK")] : []

let package = Package(
    name: "OpenObserve",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS("12.6"),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "OpenObserveCore",
            targets: ["OpenObserveCore"]
        ),
        .library(
            name: "OpenObserveLogs",
            targets: ["OpenObserveLogs"]
        ),
        .library(
            name: "OpenObserveTrace",
            targets: ["OpenObserveTrace"]
        ),
        .library(
            name: "OpenObserveRUM",
            targets: ["OpenObserveRUM"]
        ),
        .library(
            name: "OpenObserveSessionReplay",
            targets: ["OpenObserveSessionReplay"]
        ),
        .library(
            name: "OpenObserveCrashReporting",
            targets: ["OpenObserveCrashReporting"]
        ),
        .library(
            name: "OpenObserveWebViewTracking",
            targets: ["OpenObserveWebViewTracking"]
        ),
        .library(
            name: "OpenObserveFlags",
            targets: ["OpenObserveFlags"]
        ),
        .library(
            name: "OpenObserveProfiling",
            targets: ["OpenObserveProfiling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "2.5.0"),
        .package(url: "https://github.com/open-telemetry/opentelemetry-swift-core", .upToNextMinor(from: "2.3.0")),
    ],
    targets: [
        .target(
            name: "OpenObserveCore",
            dependencies: [
                .target(name: "OpenObserveInternal"),
                .target(name: "OpenObservePrivate"),
            ],
            path: "OpenObserveCore",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [.define("SPM_BUILD")] + internalSwiftSettings
        ),
        .target(
            name: "OpenObservePrivate",
            path: "OpenObserveCore/Private"
        ),

        .target(
            name: "OpenObserveInternal",
            path: "OpenObserveInternal/Sources",
            swiftSettings: internalSwiftSettings
        ),
        .testTarget(
            name: "OpenObserveInternalTests",
            dependencies: [
                .target(name: "OpenObserveInternal"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveInternal/Tests"
        ),

        .target(
            name: "OpenObserveLogs",
            dependencies: [
                .target(name: "OpenObserveInternal"),
            ],
            path: "OpenObserveLogs/Sources"
        ),
        .testTarget(
            name: "OpenObserveLogsTests",
            dependencies: [
                .target(name: "OpenObserveLogs"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveLogs/Tests"
        ),

        .target(
            name: "OpenObserveTrace",
            dependencies: [
                .target(name: "OpenObserveInternal"),
                .product(name: "OpenTelemetryApi", package: "opentelemetry-swift-core")
            ],
            path: "OpenObserveTrace/Sources"
        ),
        .testTarget(
            name: "OpenObserveTraceTests",
            dependencies: [
                .target(name: "OpenObserveTrace"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveTrace/Tests"
        ),

        .target(
            name: "OpenObserveRUM",
            dependencies: [
                .target(name: "OpenObserveInternal"),
            ],
            path: "OpenObserveRUM",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "OpenObserveRUMTests",
            dependencies: [
                .target(name: "OpenObserveRUM"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveRUM/Tests"
        ),

        .target(
            name: "OpenObserveCrashReporting",
            dependencies: [
                .target(name: "OpenObserveInternal"),
                .product(name: "Recording", package: "KSCrash"),
                .product(name: "Filters", package: "KSCrash")
            ],
            path: "OpenObserveCrashReporting",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "OpenObserveCrashReportingTests",
            dependencies: [
                .target(name: "OpenObserveCrashReporting"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveCrashReporting/Tests"
        ),

        .target(
            name: "OpenObserveWebViewTracking",
            dependencies: [
                .target(name: "OpenObserveInternal"),
            ],
            path: "OpenObserveWebViewTracking/Sources"
        ),
        .testTarget(
            name: "OpenObserveWebViewTrackingTests",
            dependencies: [
                .target(name: "OpenObserveWebViewTracking"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveWebViewTracking/Tests"
        ),

        .target(
            name: "OpenObserveSessionReplay",
            dependencies: ["OpenObserveInternal"],
            path: "OpenObserveSessionReplay/Sources"
        ),
        .testTarget(
            name: "OpenObserveSessionReplayTests",
            dependencies: [
                .target(name: "OpenObserveSessionReplay"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveSessionReplay/Tests",
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        
        .target(
            name: "OpenObserveProfiling",
            dependencies: [
                .target(name: "OpenObserveInternal"),
                .target(name: "OpenObserveMachProfiler")
            ],
            path: "OpenObserveProfiling",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ],
            swiftSettings: internalSwiftSettings
        ),
        .target(
            name: "OpenObserveMachProfiler",
            path: "OpenObserveProfiling/Mach"
        ),
        .testTarget(
            name: "OpenObserveProfilingTests",
            dependencies: [
                .target(name: "OpenObserveMachProfiler"),
                .target(name: "OpenObserveProfiling"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveProfiling/Tests",
            swiftSettings: [.interoperabilityMode(.Cxx)] + internalSwiftSettings
        ),

        .target(
            name: "OpenObserveFlags",
            dependencies: [
                .target(name: "OpenObserveInternal"),
            ],
            path: "OpenObserveFlags/Sources"
        ),
        .testTarget(
            name: "OpenObserveFlagsTests",
            dependencies: [
                .target(name: "OpenObserveFlags"),
                .target(name: "TestUtilities"),
            ],
            path: "OpenObserveFlags/Tests"
        ),

        .target(
            name: "TestUtilities",
            dependencies: [
                .target(name: "OpenObserveCore"),
                .target(name: "OpenObservePrivate"),
                .target(name: "OpenObserveInternal"),
                .target(name: "OpenObserveLogs"),
                .target(name: "OpenObserveRUM"),
                .target(name: "OpenObserveSessionReplay"),
                .target(name: "OpenObserveTrace"),
                .target(name: "OpenObserveCrashReporting"),
                .target(name: "OpenObserveWebViewTracking"),
                .target(name: "OpenObserveFlags")
            ],
            path: "TestUtilities/Sources",
            swiftSettings: [.define("SPM_BUILD")] + internalSwiftSettings
        )
    ],
    cxxLanguageStandard: .cxx17
)

// If the `DD_TEST_UTILITIES_ENABLED` development ENV is set, export additional utility packages.
// To set this ENV for Xcode projects that fetch this package locally, use `open --env DD_TEST_UTILITIES_ENABLED path/to/<project or workspace>`.
if ProcessInfo.processInfo.environment["DD_TEST_UTILITIES_ENABLED"] != nil {
    package.products.append(
        .library(
            name: "TestUtilities",
            targets: ["TestUtilities"]
        )
    )
}
