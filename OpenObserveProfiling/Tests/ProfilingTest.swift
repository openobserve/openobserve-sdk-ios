/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if !os(watchOS)

import XCTest
import OpenObserveInternal
import TestUtilities

@testable import OpenObserveProfiling
import OpenObserveMachProfiler

class ProfilingTest: XCTestCase {
    func testProfilingConfiguration() throws {
        // Given
        let configuration = Profiling.Configuration(customEndpoint: .mockRandom())
        let core = SingleFeatureCoreMock<ProfilerFeature>()
        ctor_profiler_start_testing(100, false, 5.seconds.dd.toInt64Nanoseconds)
        defer { ctor_profiler_destroy() }

        // When
        Profiling.enable(with: configuration, in: core)

        // Then
        let feature = core.feature(named: ProfilerFeature.name, type: ProfilerFeature.self)
        let requestBuilder = feature?.requestBuilder as? RequestBuilder
        XCTAssertEqual(feature?.performanceOverride?.maxFileSize, .min)
        XCTAssertEqual(requestBuilder?.customUploadURL, configuration.customEndpoint)
        XCTAssertEqual(feature?.telemetryController.sampleRate, 20)

        let context = try XCTUnwrap(core.context.additionalContext(ofType: ProfilingContext.self))
        XCTAssertEqual(context.status, .running)
    }
}

#endif
