/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
@testable import OpenObserveRUM

final class AppLaunchMetricControllerTests: XCTestCase {
    private let telemetry = TelemetryMock()

    func testTrackingAppLaunchMetric() throws {
        // Given
        let ooContext: OpenObserveContext = .mockRandom()
        let vitalEvent: RUMVitalAppLaunchEvent = .mockWith(
            vital: .mockWith(
                appLaunchMetric: .ttid,
                isPrewarmed: ooContext.launchInfo.launchReason == .prewarming
            )
        )
        let coldStartRule: ColdStartRule = .appUpdate
        let controller = AppLaunchMetricController(telemetry: telemetry)

        // When
        controller.track(coldStartRule: coldStartRule)
        controller.track(ttidEvent: vitalEvent, context: ooContext)
        controller.sendMetric()

        // Then
        let metric = try XCTUnwrap(telemetry.messages.appLaunchMetric)
        XCTAssertEqual(metric.ttidDurationNs, vitalEvent.vital.duration.dd.toInt64Nanoseconds)
        XCTAssertEqual(metric.startupType, vitalEvent.vital.startupType?.rawValue)
        XCTAssertEqual(metric.coldStartRule, coldStartRule.rawValue)
        XCTAssertEqual(metric.isPrewarmed, vitalEvent.vital.isPrewarmed)
        XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
        XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
        XCTAssertEqual(metric.pois.count, 5)

        let metricTelemetry = try XCTUnwrap(telemetry.messages.lastMetric(named: AppLaunchMetric.Constants.name))
        XCTAssertEqual(metricTelemetry.sampleRate, 20.0)
    }

    func testTrackingLargeTTID() throws {
        // Given
        let ooContext: OpenObserveContext = .mockRandom()
        let controller = AppLaunchMetricController(telemetry: telemetry)
        let duration: TimeInterval = 1_000

        // When
        controller.send(metric: .largeTTID(context: ooContext, duration: duration))

        // Then
        let metric = try XCTUnwrap(telemetry.messages.appLaunchMetric)
        XCTAssertEqual(metric.ttidDurationNs, duration.dd.toInt64Nanoseconds)
        XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
        XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
        XCTAssertEqual(metric.isPrewarmed, ooContext.launchInfo.launchReason == .prewarming)
        XCTAssertEqual(metric.pois.count, 5)
        XCTAssertFalse(metric.errorMessage?.isEmpty ?? true)

        let metricTelemetry = try XCTUnwrap(telemetry.messages.lastMetric(named: AppLaunchMetric.Constants.name))
        XCTAssertEqual(metricTelemetry.sampleRate, 20.0)
    }

    func testTrackingLaunchNotSupported() throws {
        // Given
        let ooContext: OpenObserveContext = .mockRandom()
        let controller = AppLaunchMetricController(telemetry: telemetry)
        let duration: TimeInterval = 1_000

        // When
        controller.send(metric: .launchNotSupported(context: ooContext, duration: duration))

        // Then
        let metric = try XCTUnwrap(telemetry.messages.appLaunchMetric)
        XCTAssertEqual(metric.ttidDurationNs, duration.dd.toInt64Nanoseconds)
        XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
        XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
        XCTAssertEqual(metric.isPrewarmed, ooContext.launchInfo.launchReason == .prewarming)
        XCTAssertEqual(metric.pois.count, 5)
        XCTAssertFalse(metric.errorMessage?.isEmpty ?? true)

        let metricTelemetry = try XCTUnwrap(telemetry.messages.lastMetric(named: AppLaunchMetric.Constants.name))
        XCTAssertEqual(metricTelemetry.sampleRate, 20.0)
    }

    func testTrackingAppLaunchMetric_withTTFDRecordedFirst() throws {
        // Given
        let ooContext: OpenObserveContext = .mockRandom()
        let vitalEvent: RUMVitalAppLaunchEvent = .mockAny()
        let controller = AppLaunchMetricController(telemetry: telemetry)
        let ttfdDuration: Int64 = 1_000

        // When
        controller.track(ttidEvent: vitalEvent, context: ooContext)
        controller.trackTTFD(duration: ttfdDuration)
        controller.sendMetric()

        // Then
        let metric = try XCTUnwrap(telemetry.messages.appLaunchMetric)
        XCTAssertEqual(metric.ttidDurationNs, vitalEvent.vital.duration.dd.toInt64Nanoseconds)
        XCTAssertEqual(metric.startupType, vitalEvent.vital.startupType?.rawValue)
        XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
        XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
        XCTAssertEqual(metric.pois.count, 5)
        XCTAssertEqual(metric.ttfdDurationNs, ttfdDuration)

        let metricTelemetry = try XCTUnwrap(telemetry.messages.lastMetric(named: AppLaunchMetric.Constants.name))
        XCTAssertEqual(metricTelemetry.sampleRate, 20.0)
    }

    func testTrackingMoreThanOneTTID() throws {
        // Given
        let ooContext: OpenObserveContext = .mockRandom()
        let vitalEvent: RUMVitalAppLaunchEvent = .mockAny()
        let controller = AppLaunchMetricController(telemetry: telemetry)

        // When
        controller.track(ttidEvent: vitalEvent, context: ooContext)
        controller.incrementTTIDCounter()
        controller.incrementTTIDCounter()
        controller.sendMetric()

        // Then
        let metric = try XCTUnwrap(telemetry.messages.appLaunchMetric)
        XCTAssertEqual(metric.ttidDurationNs, vitalEvent.vital.duration.dd.toInt64Nanoseconds)
        XCTAssertEqual(metric.startupType, vitalEvent.vital.startupType?.rawValue)
        XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
        XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
        XCTAssertEqual(metric.pois.count, 5)
        XCTAssertEqual(metric.extraTTIDsCount, 2)

        let metricTelemetry = try XCTUnwrap(telemetry.messages.lastMetric(named: AppLaunchMetric.Constants.name))
        XCTAssertEqual(metricTelemetry.sampleRate, 20.0)
    }

    func testTrackingMultipleAppLaunchMetrics() throws {
        // Given
        let iterations = 10
        let ooContext: OpenObserveContext = .mockRandom()
        let vitalEvent: RUMVitalAppLaunchEvent = .mockAny()
        let controller = AppLaunchMetricController(telemetry: telemetry)
        let appLaunchMetric = try XCTUnwrap(AppLaunchMetric(vitalEvent: vitalEvent, context: ooContext))

        // When
        (0..<iterations).forEach { _ in
            controller.send(metric: appLaunchMetric)
        }

        // Then
        XCTAssertEqual(telemetry.messages.count, iterations)
        try (0..<iterations).forEach {
            let metric = try XCTUnwrap(telemetry.messages[$0]
                .asMetric?.attributes[AppLaunchMetric.Constants.appLaunchKey] as? AppLaunchMetric.Attributes)

            XCTAssertEqual(metric.ttidDurationNs, vitalEvent.vital.duration.dd.toInt64Nanoseconds)
            XCTAssertEqual(metric.startupType, vitalEvent.vital.startupType?.rawValue)
            XCTAssertEqual(metric.launchReason, ooContext.launchInfo.launchReason)
            XCTAssertEqual(metric.taskPolicyRole, ooContext.launchInfo.raw.taskPolicyRole)
            XCTAssertEqual(metric.pois.count, 5)
        }
    }
}

// MARK: - Helpers

private extension Array where Element == TelemetryMessage {
    var appLaunchMetric: AppLaunchMetric.Attributes? {
        lastMetric(named: AppLaunchMetric.Constants.name)?
            .attributes[AppLaunchMetric.Constants.appLaunchKey] as? AppLaunchMetric.Attributes
    }
}
