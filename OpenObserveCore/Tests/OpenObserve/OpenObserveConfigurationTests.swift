/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal

@testable import OpenObserveCore

class OpenObserveConfigurationTests: XCTestCase {
    private var printFunction: PrintFunctionSpy! // swiftlint:disable:this implicitly_unwrapped_optional
    private var defaultConfig = OpenObserve.Configuration(clientToken: "abc-123", env: "tests")

    override func setUp() {
        super.setUp()

        XCTAssertFalse(OpenObserve.isInitialized())
        printFunction = PrintFunctionSpy()
        consolePrint = printFunction.print
    }

    override func tearDown() {
        consolePrint = { message, _ in print(message) }
        printFunction = nil
        XCTAssertFalse(OpenObserve.isInitialized())
        super.tearDown()
    }

    // MARK: - Initializing with different configurations

    func testDefaultConfiguration() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            bundleIdentifier: "test",
            CFBundleShortVersionString: "1.0.0",
            CFBundleExecutable: "Test"
        )

        XCTAssertEqual(configuration.batchSize, .medium)
        XCTAssertEqual(configuration.uploadFrequency, .average)
        XCTAssertEqual(configuration.additionalConfiguration.count, 0)
        XCTAssertNil(configuration.encryption)
        XCTAssertTrue(configuration.serverDateProvider is OpenObserveNTPDateProvider)

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .granted
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let urlSessionClient = try XCTUnwrap(core.httpClient as? URLSessionClient)
        XCTAssertTrue(core.dateProvider is SystemDateProvider)
        XCTAssertNil(urlSessionClient.session.configuration.connectionProxyDictionary)
        XCTAssertNil(core.encryption)

        let context = core.contextProvider.read()
        XCTAssertEqual(context.clientToken, "abc-123")
        XCTAssertEqual(context.env, "tests")
        XCTAssertEqual(context.site, .us1)
        XCTAssertEqual(context.service, "test")
        XCTAssertEqual(context.version, "1.0.0")
        XCTAssertEqual(context.sdkVersion, __sdkVersion)
        XCTAssertEqual(context.applicationName, "Test")
        XCTAssertNil(context.variant)
        XCTAssertEqual(context.source, "ios")
        XCTAssertEqual(context.applicationBundleIdentifier, "test")
        XCTAssertEqual(context.trackingConsent, .granted)
    }

    func testAdvancedConfiguration() throws {
        var configuration = defaultConfig

        configuration.service = "service-name"
        configuration.site = .eu1
        configuration.batchSize = .small
        configuration.uploadFrequency = .frequent
        configuration.batchProcessingLevel = .high
        #if !os(watchOS)
        configuration.proxyConfiguration = [
            kCFNetworkProxiesHTTPEnable: true,
            kCFNetworkProxiesHTTPPort: 123,
            kCFNetworkProxiesHTTPProxy: "www.example.com",
            kCFProxyUsernameKey: "proxyuser",
            kCFProxyPasswordKey: "proxypass",
        ]
        #endif
        configuration.bundle = .mockWith(
            bundleIdentifier: "test",
            CFBundleShortVersionString: "1.0.0",
            CFBundleExecutable: "Test"
        )
        configuration.encryption = DataEncryptionMock()
        configuration.serverDateProvider = ServerDateProviderMock()
        configuration._internal_mutation {
            $0.additionalConfiguration = [
                CrossPlatformAttributes.oosource: "cp-source",
                CrossPlatformAttributes.variant: "cp-variant",
                CrossPlatformAttributes.sdkVersion: "cp-version"
            ]
        }

        XCTAssertEqual(configuration.batchSize, .small)
        XCTAssertEqual(configuration.uploadFrequency, .frequent)
        XCTAssertEqual(configuration.batchProcessingLevel, .high)
        XCTAssertTrue(configuration.encryption is DataEncryptionMock)
        XCTAssertTrue(configuration.serverDateProvider is ServerDateProviderMock)

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .pending
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        XCTAssertTrue(core.dateProvider is SystemDateProvider)
        XCTAssertTrue(core.encryption is DataEncryptionMock)

        #if !os(watchOS)
        let urlSessionClient = try XCTUnwrap(core.httpClient as? URLSessionClient)
        let connectionProxyDictionary = try XCTUnwrap(urlSessionClient.session.configuration.connectionProxyDictionary)
        XCTAssertEqual(connectionProxyDictionary[kCFNetworkProxiesHTTPEnable] as? Bool, true)
        XCTAssertEqual(connectionProxyDictionary[kCFNetworkProxiesHTTPPort] as? Int, 123)
        XCTAssertEqual(connectionProxyDictionary[kCFNetworkProxiesHTTPProxy] as? String, "www.example.com")
        XCTAssertEqual(connectionProxyDictionary[kCFProxyUsernameKey] as? String, "proxyuser")
        XCTAssertEqual(connectionProxyDictionary[kCFProxyPasswordKey] as? String, "proxypass")
        #endif

        let context = core.contextProvider.read()
        XCTAssertEqual(context.clientToken, "abc-123")
        XCTAssertEqual(context.env, "tests")
        XCTAssertEqual(context.site, .eu1)
        XCTAssertEqual(context.service, "service-name")
        XCTAssertEqual(context.version, "1.0.0")
        XCTAssertEqual(context.sdkVersion, "cp-version")
        XCTAssertEqual(context.applicationName, "Test")
        XCTAssertEqual(context.variant, "cp-variant")
        XCTAssertEqual(context.source, "cp-source")
        XCTAssertEqual(context.applicationBundleIdentifier, "test")
        XCTAssertEqual(context.trackingConsent, .pending)
    }

    func testGivenDefaultConfiguration_itCanBeInitialized() {
        OpenObserve.initialize(
            with: defaultConfig,
            trackingConsent: .mockRandom()
        )

        XCTAssertTrue(OpenObserve.isInitialized())
        OpenObserve.flushAndDeinitialize()
    }

    func testGivenInvalidConfiguration_itPrintsError() {
        let invalidConfiguration = OpenObserve.Configuration(clientToken: "", env: "tests")

        OpenObserve.initialize(
            with: invalidConfiguration,
            trackingConsent: .mockRandom()
        )

        XCTAssertEqual(
            printFunction.printedMessage,
            "🔥 OpenObserve SDK usage error: `clientToken` cannot be empty."
        )
        XCTAssertFalse(OpenObserve.isInitialized())
    }

    func testGivenValidConfiguration_whenInitializedMoreThanOnce_itPrintsError() {
        OpenObserve.initialize(
            with: defaultConfig,
            trackingConsent: .mockRandom()
        )

        OpenObserve.initialize(
            with: defaultConfig,
            trackingConsent: .mockRandom()
        )

        XCTAssertEqual(
            printFunction.printedMessage,
            "🔥 OpenObserve SDK usage error: The 'main' instance of SDK is already initialized."
        )

        OpenObserve.flushAndDeinitialize()
    }

    func testGivenNoExecutable_itUsesBundleTypeAsApplicationName() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            CFBundleExecutable: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationName, "iOSApp")
    }

    func testGivenNoExecutable_andWidgetExecutable_itUsesBundleTypeAsApplicationName() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            bundlePath: "widget.appex",
            CFBundleExecutable: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationName, "iOSAppExtension")
    }

    func testGivenNoBundleVersion_itUsesShortVersionString() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            CFBundleVersion: nil,
            CFBundleShortVersionString: "1.2.3"
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.version, "1.2.3")
    }

    func testGivenNoBundleShortVersion_itUsesDefaultValue() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            CFBundleVersion: nil,
            CFBundleShortVersionString: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.version, "0.0.0")
        XCTAssertEqual(context.buildNumber, "0")
    }

    func testGivenNoBundleVersion_itUsesDefaultValue() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            CFBundleVersion: "FFFFF",
            CFBundleShortVersionString: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.buildNumber, "FFFFF")
    }

    func testGivenNoBundleIdentifier_itUsesDefaultValues() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            bundleIdentifier: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationBundleIdentifier, "unknown")
        XCTAssertEqual(context.service, "ios")
    }

    func testGivenNoBundleIdentifier_itUsesUnknown() throws {
        var configuration = defaultConfig

        configuration.bundle = .mockWith(
            bundleIdentifier: nil
        )

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationBundleIdentifier, "unknown")
    }

    func testiOSAppBundleType() throws {
        var configuration = defaultConfig
        configuration.bundle = .mockWith(bundlePath: "bundle.path.app")

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationBundleType, .iOSApp)
    }

    func testiOSAppExtensionBundleType() throws {
        var configuration = defaultConfig
        configuration.bundle = .mockWith(bundlePath: "bundle.path.appex")

        OpenObserve.initialize(
            with: configuration,
            trackingConsent: .mockRandom()
        )
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()
        XCTAssertEqual(context.applicationBundleType, .iOSAppExtension)
    }

    func testEnvironment() throws {
        func verify(validEnv env: String) throws {
            OpenObserve.initialize(
                with: OpenObserve.Configuration(clientToken: "abc-123", env: env),
                trackingConsent: .mockRandom()
            )
            defer { OpenObserve.flushAndDeinitialize() }
            XCTAssertNil(printFunction.printedMessage)
        }

        func verify(invalidEnv env: String) {
            OpenObserve.initialize(
                with: OpenObserve.Configuration(clientToken: "abc-123", env: env),
                trackingConsent: .mockRandom()
            )
            XCTAssertEqual(
                printFunction.printedMessage,
                "🔥 OpenObserve SDK usage error: `env`: \(env) contains illegal characters (only alphanumerics and `_` are allowed)"
            )
        }

        try verify(validEnv: "staging_1")
        try verify(validEnv: "production")
        try verify(validEnv: "production:some")
        try verify(validEnv: "pro/d-uct.ion_")

        verify(invalidEnv: "")
        verify(invalidEnv: "*^@!&#")
        verify(invalidEnv: "abc def")
        verify(invalidEnv: "*^@!&#")
        verify(invalidEnv: "*^@!&#\nsome_env")
        verify(invalidEnv: String(repeating: "a", count: 197))
    }

    func testApplicationVersionOverride() throws {
        var configuration = defaultConfig
        configuration.additionalConfiguration[CrossPlatformAttributes.version] = "5.23.2"

        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        XCTAssertEqual(context.version, "5.23.2")
    }

    func testPublicVersionProperty() throws {
        var configuration = defaultConfig
        configuration.version = "my-completely-custom-version"
        configuration.bundle = .mockWith(
            CFBundleShortVersionString: "1.0.0"
        )

        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        XCTAssertEqual(context.version, "my-completely-custom-version")
    }

    func testPublicVersionPropertyWithNilUsesBundle() throws {
        var configuration = defaultConfig
        configuration.version = nil
        configuration.bundle = .mockWith(
            CFBundleShortVersionString: "1.5.0"
        )

        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        XCTAssertEqual(context.version, "1.5.0")
    }

    func testCrossPlatformVersionOverridesTakePrecedenceOverPublicVersion() throws {
        var configuration = defaultConfig
        configuration.version = "2.0.0-native"
        configuration.bundle = .mockWith(
            CFBundleShortVersionString: "1.0.0"
        )
        configuration.additionalConfiguration[CrossPlatformAttributes.version] = "3.0.0-crossplatform"

        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        // Cross-platform override should take precedence
        XCTAssertEqual(context.version, "3.0.0-crossplatform")
    }

    func testGivenBuildId_itSetsContext() throws {
        // Given
        let buildId: String = .mockRandom(length: 32)
        var configuration = defaultConfig
        configuration.additionalConfiguration[CrossPlatformAttributes.buildId] = buildId

        // When
        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        // Then
        XCTAssertEqual(context.buildId, buildId)
    }

    func testGivenNativeSourceType_itSetsInContext() throws {
        // Given
        let nativeSourceType: String = .mockRandom()
        var configuration = defaultConfig
        configuration.additionalConfiguration[CrossPlatformAttributes.nativeSourceType] = nativeSourceType

        // When
        OpenObserve.initialize(with: configuration, trackingConsent: .mockRandom())
        defer { OpenObserve.flushAndDeinitialize() }

        let core = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore)
        let context = core.contextProvider.read()

        // Then
        XCTAssertEqual(context.nativeSourceOverride, nativeSourceType)
    }
}
