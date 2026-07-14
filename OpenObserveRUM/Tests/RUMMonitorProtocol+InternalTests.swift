/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@testable import OpenObserveRUM

class RUMMonitorProtocol_InternalTests: XCTestCase {
    func testInternalInterfaceIsAvailableOnMonitor() {
        let monitor: RUMMonitorProtocol

        // When
        monitor = Monitor(
            dependencies: .mockAny(),
            dateProvider: SystemDateProvider()
        )

        // Then
        XCTAssertIdentical(monitor._internal?.monitor, monitor)
    }

    func testInternalInterfaceIsNotAvailableOnNOPMonitor() {
        let monitor: RUMMonitorProtocol

        // When
        monitor = NOPMonitor()

        // Then
        XCTAssertNil(monitor._internal)
    }
}
