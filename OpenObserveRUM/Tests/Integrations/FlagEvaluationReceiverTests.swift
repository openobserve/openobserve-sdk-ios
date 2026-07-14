/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
@testable import TestUtilities

@testable import OpenObserveRUM

class FlagEvaluationReceiverTests: XCTestCase {
    private let featureScope = FeatureScopeMock()

    func testReceiveFlagEvaluationMessage() throws {
        // Given
        let receiver = FlagEvaluationReceiver(
            monitor: Monitor(
                dependencies: .mockWith(featureScope: featureScope),
                dateProvider: SystemDateProvider()
            )
        )
        let message: FeatureMessage = .payload(
            RUMFlagEvaluationMessage(
                flagKey: "feature-flag",
                value: true
            )
        )

        // When
        let result = receiver.receive(message: message, from: NOPOpenObserveCore())

        // Then
        XCTAssertTrue(result, "It must accept the message")

        let viewEvents: [RUMViewEvent] = featureScope.eventsWritten()
        XCTAssertFalse(viewEvents.isEmpty, "It should write a view event")

        let lastViewEvent = try XCTUnwrap(viewEvents.last)
        let featureFlags = try XCTUnwrap(lastViewEvent.featureFlags)
        XCTAssertEqual(featureFlags.featureFlagsInfo["feature-flag"] as? Bool, true)
    }
}
