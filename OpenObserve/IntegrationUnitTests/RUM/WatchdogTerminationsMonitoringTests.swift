/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
import OpenObserveCrashReporting
@testable import OpenObserveRUM

class WatchdogTerminationsMonitoringTests: XCTestCase {
    var core: OpenObserveCoreProxy! // swiftlint:disable:this implicitly_unwrapped_optional
    var rumConfig = RUM.Configuration(applicationID: .mockAny())
    let device: DeviceInfo = .init(
        name: .mockAny(),
        model: .mockAny(),
        osName: .mockAny(),
        architecture: .mockAny(),
        isSimulator: false,
        vendorId: .mockAny(),
        isDebugging: false,
        systemBootTime: .init(),
        logicalCpuCount: .mockRandom(),
        totalRam: .mockRandom()
    )

    override func setUp() {
        super.setUp()
        core = OpenObserveCoreProxy()
        rumConfig.trackWatchdogTerminations = true
    }

        override func tearDownWithError() throws {
        try core.flushAndTearDown()
        core = nil

        super.tearDown()
    }

    func testGivenRUMAndCrashReportingEnabled_whenWatchdogTerminatesTheApp_thenWatchdogTerminationEventIsReported() throws {
        // given
        core.context = .mockWith(
            device: device,
            trackingConsent: .granted,
            applicationStateHistory: .mockAppInForeground()
        )
        rumConfig.processID = .mockRandom()
        oneOf(
            [ // no matter of RUM or CR initialization order
                {
                    RUM.enable(with: self.rumConfig, in: self.core)
                    CrashReporting.enable(in: self.core)
                },
                {
                    CrashReporting.enable(in: self.core)
                    RUM.enable(with: self.rumConfig, in: self.core)
                },
            ]
        )

        try waitForWatchdogTerminationCheck(core: core)
        let monitor = RUMMonitor.shared(in: core)
        monitor.startView(key: "foo")
        let views = core.waitAndReturnEvents(ofFeature: RUMFeature.name, ofType: RUMViewEvent.self)
        let errorsBeforeCrash = core.waitAndReturnEvents(ofFeature: RUMFeature.name, ofType: RUMErrorEvent.self)
        XCTAssertEqual(errorsBeforeCrash.count, 0)

        let erroringView = try XCTUnwrap(views.last)
        XCTAssertEqual(erroringView.view.name, "foo")

        core.context = .mockWith(
            device: device,
            trackingConsent: .pending,
            applicationStateHistory: .mockAppInForeground()
        )

        // re-enable RUM to trigger the watchdog termination event
        // update the process ID to make sure check treats it as a new app launch
        rumConfig.processID = .mockRandom()
        oneOf(
            [ // no matter of RUM or CR initialization order
                {
                    RUM.enable(with: self.rumConfig, in: self.core)
                    CrashReporting.enable(in: self.core)
                },
                {
                    CrashReporting.enable(in: self.core)
                    RUM.enable(with: self.rumConfig, in: self.core)
                },
            ]
        )

        try waitForWatchdogTerminationCheck(core: core)

        let errors = core.waitAndReturnEvents(ofFeature: RUMFeature.name, ofType: RUMErrorEvent.self)
        let watchdogCrash = try XCTUnwrap(errors.first)
        XCTAssertEqual(watchdogCrash.error.stack, WatchdogTerminationReporter.Constants.stackNotAvailableErrorMessage)
        XCTAssertEqual(watchdogCrash.view.name, "foo")

        XCTAssertEqual(watchdogCrash.error.message, WatchdogTerminationReporter.Constants.errorMessage)
        XCTAssertEqual(watchdogCrash.error.type, WatchdogTerminationReporter.Constants.errorType)
        XCTAssertEqual(watchdogCrash.error.source, .source)
        XCTAssertEqual(watchdogCrash.error.category, .watchdogTermination)
    }

    /// Watchdog Termination check is done in the background, we need to wait for it to finish before we can proceed with the test
    /// - Parameter core: `OpenObserveCoreProxy` instance
    func waitForWatchdogTerminationCheck(core: OpenObserveCoreProxy) throws {
        let watchdogTermination = try XCTUnwrap(core.get(feature: RUMFeature.self)?.instrumentation.watchdogTermination)
        while watchdogTermination.currentState != .started {
            Thread.sleep(forTimeInterval: .fromMilliseconds(100))
        }
    }
}
