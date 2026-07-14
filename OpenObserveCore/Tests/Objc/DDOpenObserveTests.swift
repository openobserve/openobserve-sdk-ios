/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import XCTest
import TestUtilities

@testable import OpenObserveInternal
@testable import OpenObserveLogs
@_spi(objc)
@testable import OpenObserveCore

/// These tests verify that Objc APIs properly interact with`OpenObserve` public API (swift).
class DDOpenObserveTests: XCTestCase {
    override func setUp() {
        super.setUp()
        XCTAssertFalse(OpenObserve.isInitialized())
    }

    override func tearDown() {
        XCTAssertFalse(OpenObserve.isInitialized())
        super.tearDown()
    }

    // MARK: - SDK initialization / stop lifecycle

    func testItForwardsInitializationToSwift() throws {
        let config = objc_Configuration(
            clientToken: "abcefghi",
            env: "tests"
        )

        config.bundle = .mockWith(CFBundleExecutable: "app-name")

        objc_OpenObserve.initialize(
            configuration: config,
            trackingConsent: randomConsent().objc
        )

        XCTAssertTrue(OpenObserve.isInitialized())

        let context = try XCTUnwrap(CoreRegistry.default as? OpenObserveCore).contextProvider.read()
        XCTAssertEqual(context.applicationName, "app-name")
        XCTAssertEqual(context.env, "tests")

        OpenObserve.flushAndDeinitialize()

        XCTAssertNil(CoreRegistry.default.get(feature: LogsFeature.self))
    }

    func testItReflectsInitializationStatus() throws {
        let config = objc_Configuration(
            clientToken: "abcefghi",
            env: "tests"
        )

        config.bundle = .mockWith(CFBundleExecutable: "app-name")
        XCTAssertFalse(objc_OpenObserve.isInitialized())

        objc_OpenObserve.initialize(
            configuration: config,
            trackingConsent: randomConsent().objc
        )

        XCTAssertTrue(objc_OpenObserve.isInitialized())

        OpenObserve.flushAndDeinitialize()

        XCTAssertNil(CoreRegistry.default.get(feature: LogsFeature.self))
    }

    func testItForwardsStopInstanceToSwift() throws {
        let config = objc_Configuration(
            clientToken: "abcefghi",
            env: "tests"
        )

        config.bundle = .mockWith(CFBundleExecutable: "app-name")

        objc_OpenObserve.initialize(
            configuration: config,
            trackingConsent: randomConsent().objc
        )

        XCTAssertTrue(OpenObserve.isInitialized())

        objc_OpenObserve.stopInstance()

        XCTAssertFalse(OpenObserve.isInitialized())

        XCTAssertNil(CoreRegistry.default.get(feature: LogsFeature.self))
    }

    // MARK: - Changing Tracking Consent

    func testItForwardsTrackingConsentToSwift() {
        let initialConsent = randomConsent()
        let nextConsent = randomConsent()

        objc_OpenObserve.initialize(
            configuration: objc_Configuration(clientToken: "abcefghi", env: "tests"),
            trackingConsent: initialConsent.objc
        )

        let core = CoreRegistry.default as? OpenObserveCore
        XCTAssertEqual(core?.consentPublisher.consent, initialConsent.swift)

        objc_OpenObserve.setTrackingConsent(consent: nextConsent.objc)

        XCTAssertEqual(core?.consentPublisher.consent, nextConsent.swift)

        OpenObserve.flushAndDeinitialize()
    }

    // MARK: - Setting user info

    func testItForwardsUserInfoToSwift() throws {
        objc_OpenObserve.initialize(
            configuration: objc_Configuration(clientToken: "abcefghi", env: "tests"),
            trackingConsent: randomConsent().objc
        )

        let core = CoreRegistry.default as? OpenObserveCore
        let userInfo = try XCTUnwrap(core?.userInfoPublisher)

        objc_OpenObserve.setUserInfo(
            userId: "id",
            name: "name",
            email: "email",
            extraInfo: [
                "attribute-int": 42,
                "attribute-double": 42.5,
                "attribute-string": "string value"
            ]
        )
        objc_OpenObserve.addUserExtraInfo(["foo": "bar"])
        XCTAssertEqual(userInfo.current.id, "id")
        XCTAssertEqual(userInfo.current.name, "name")
        XCTAssertEqual(userInfo.current.email, "email")
        let extraInfo = userInfo.current.extraInfo
        XCTAssertEqual(extraInfo["attribute-int"]?.dd.decode(), 42)
        XCTAssertEqual(extraInfo["attribute-double"]?.dd.decode(), 42.5)
        XCTAssertEqual(extraInfo["attribute-string"]?.dd.decode(), "string value")
        XCTAssertEqual(extraInfo["foo"]?.dd.decode(), "bar")

        objc_OpenObserve.setUserInfo(userId: "id", name: nil, email: nil, extraInfo: [:])
        XCTAssertNotNil(userInfo.current.id)
        XCTAssertNil(userInfo.current.name)
        XCTAssertNil(userInfo.current.email)
        XCTAssertTrue(userInfo.current.extraInfo.isEmpty)

        OpenObserve.flushAndDeinitialize()
    }

    // MARK: - Changing SDK verbosity level

    private let swiftVerbosityLevels: [CoreLoggerLevel?] = [
        .debug, .warn, .error, .critical, nil
    ]
    private let objcVerbosityLevels: [objc_CoreLoggerLevel] = [
        .debug, .warn, .error, .critical, .none
    ]

    func testItForwardsSettingVerbosityLevelToSwift() {
        defer { OpenObserve.verbosityLevel = nil }

        zip(swiftVerbosityLevels, objcVerbosityLevels).forEach { swiftLevel, objcLevel in
            objc_OpenObserve.setVerbosityLevel(objcLevel)
            XCTAssertEqual(OpenObserve.verbosityLevel, swiftLevel)
        }
    }

    func testItGetsVerbosityLevelFromSwift() {
        defer { OpenObserve.verbosityLevel = nil }

        zip(swiftVerbosityLevels, objcVerbosityLevels).forEach { swiftLevel, objcLevel in
            OpenObserve.verbosityLevel = swiftLevel
            XCTAssertEqual(objc_OpenObserve.verbosityLevel(), objcLevel)
        }
    }

    // MARK: - Helpers

    private func randomConsent() -> (objc: objc_TrackingConsent, swift: TrackingConsent) {
        let objcConsents: [objc_TrackingConsent] = [.granted(), .notGranted(), .pending()]
        let swiftConsents: [TrackingConsent] = [.granted, .notGranted, .pending]
        let index: Int = .random(in: 0..<3)
        return (objc: objcConsents[index], swift: swiftConsents[index])
    }
}
