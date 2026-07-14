/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@testable import OpenObserveCore

class AccountInfoPublisherTests: XCTestCase {
    func testNilInitialValue() throws {
        let publisher = AccountInfoPublisher()
        DDAssertReflectionEqual(publisher.initialValue, nil)
    }

    func testPublishAccountInfo() throws {
        let expectation = expectation(description: "account info publisher publishes data")

        // Given
        let publisher = AccountInfoPublisher()
        let accountInfo: AccountInfo = .mockRandom()

        // When
        publisher.publish {
            // Then
            DDAssertReflectionEqual($0, accountInfo)
            expectation.fulfill()
        }

        publisher.current = accountInfo

        // AccountInfoPublisher publishes in sync
        waitForExpectations(timeout: 0)
    }
}
