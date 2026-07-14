/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if !os(watchOS)

import XCTest
import OpenObserveInternal
import OpenObserveMachProfiler
import TestUtilities
@testable import OpenObserveProfiling

final class ProfilerFeatureTests: XCTestCase {
    private let requestBuilder: FeatureRequestBuilder = FeatureRequestBuilderMock()
    private let messageReceiver: FeatureMessageReceiver = NOPFeatureMessageReceiver()
    private let telemetryController = ProfilingTelemetryController()

    private var userDefaults: UserDefaults! //swiftlint:disable:this implicitly_unwrapped_optional
    private let suiteName = "ProfilerFeatureTests-\(UUID().uuidString)"

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        super.tearDown()
    }

    func testInit_setsIsEnabledFlagToTrue() {
        // Given
        XCTAssertNil(userDefaults.value(forKey: DD_PROFILING_IS_ENABLED_KEY))

        // When
        _ = ProfilerFeature(
            requestBuilder: requestBuilder,
            messageReceiver: messageReceiver,
            sampleRate: .maxSampleRate,
            telemetryController: telemetryController,
            userDefaults: userDefaults
        )

        // Then
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_IS_ENABLED_KEY) as? Bool, true)
    }

    func testInit_setsSampleRateValue() {
        // Given
        userDefaults.removeObject(forKey: DD_PROFILING_SAMPLE_RATE_KEY)
        let newSampleRate: SampleRate = 23

        // When
        _ = ProfilerFeature(
            requestBuilder: requestBuilder,
            messageReceiver: messageReceiver,
            sampleRate: newSampleRate,
            telemetryController: telemetryController,
            userDefaults: userDefaults
        )

        // Then
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_SAMPLE_RATE_KEY) as? SampleRate, newSampleRate)
    }

    func testInit_overridesPreviousSampleRate_whenNewSampleRateIsLower() {
        // Given
        let previousSampleRate: SampleRate = 80
        let lowerSampleRate: SampleRate = 20

        userDefaults.setValue(previousSampleRate, forKey: DD_PROFILING_SAMPLE_RATE_KEY)
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_SAMPLE_RATE_KEY) as? SampleRate, previousSampleRate)

        // When
        _ = ProfilerFeature(
            requestBuilder: requestBuilder,
            messageReceiver: messageReceiver,
            sampleRate: lowerSampleRate,
            telemetryController: telemetryController,
            userDefaults: userDefaults
        )

        // Then
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_SAMPLE_RATE_KEY) as? SampleRate, lowerSampleRate)
    }

    func testInit_keepsPreviousSampleRate_whenNewSampleRateIsHigher() {
        // Given
        let previousSampleRate: SampleRate = 20
        let higherSampleRate: SampleRate = 80

        userDefaults.setValue(previousSampleRate, forKey: DD_PROFILING_SAMPLE_RATE_KEY)
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_SAMPLE_RATE_KEY) as? SampleRate, previousSampleRate)

        // When
        _ = ProfilerFeature(
            requestBuilder: requestBuilder,
            messageReceiver: messageReceiver,
            sampleRate: higherSampleRate,
            telemetryController: telemetryController,
            userDefaults: userDefaults
        )

        // Then
        XCTAssertEqual(userDefaults.value(forKey: DD_PROFILING_SAMPLE_RATE_KEY) as? SampleRate, previousSampleRate)
    }
}

#endif // !os(watchOS)
