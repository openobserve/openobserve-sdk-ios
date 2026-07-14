/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@testable import OpenObserveCore

class UserInfoPublisherTests: XCTestCase {
    func testEmptyInitialValue() throws {
        let publisher = UserInfoPublisher()
        DDAssertReflectionEqual(publisher.initialValue, .empty)
    }

    func testPublishUserInfo() throws {
        let expectation = expectation(description: "user info publisher publishes data")

        // Given
        let publisher = UserInfoPublisher()
        let userInfo: UserInfo = .mockRandom()

        // When
        publisher.publish {
            // Then
            DDAssertReflectionEqual($0, userInfo)
            expectation.fulfill()
        }

        publisher.current = userInfo

        // UserInfoPublisher publishes in sync
        waitForExpectations(timeout: 0)
    }
}
