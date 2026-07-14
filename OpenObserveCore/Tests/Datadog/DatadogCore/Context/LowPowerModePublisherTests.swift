/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
@testable import OpenObserveCore

class LowPowerModePublisherTests: XCTestCase {
    private let notificationCenter = NotificationCenter()

    func testGivenInitialLowPowerModeSettingValue_whenSettingChanges_itUpdatesIsLowPowerModeEnabledValue() {
        let expectation = self.expectation(description: "Publish `isLowPowerModeEnabled`")

        // Given
        let isLowPowerModeEnabled: Bool = .random()
        let publisher = LowPowerModePublisher(
            notificationCenter: notificationCenter,
            processInfo: ProcessInfoMock(isLowPowerModeEnabled: isLowPowerModeEnabled)
        )

        XCTAssertEqual(publisher.initialValue, isLowPowerModeEnabled)

        // When
        publisher.publish {
            // Then
            XCTAssertNotEqual($0, isLowPowerModeEnabled)
            expectation.fulfill()
        }

        notificationCenter.post(
            name: .NSProcessInfoPowerStateDidChange,
            object: ProcessInfoMock(isLowPowerModeEnabled: !isLowPowerModeEnabled)
        )

        waitForExpectations(timeout: 0.5, handler: nil)
    }
}
