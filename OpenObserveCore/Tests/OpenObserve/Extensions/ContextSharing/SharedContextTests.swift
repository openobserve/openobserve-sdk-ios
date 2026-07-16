/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@_spi(Internal)
@testable import OpenObserveCore

class SharedContextTests: XCTestCase {
    func testInitializationWithOpenObserveContext_withNilAccountAndUserInfo_setsNilIds() throws {
        // Given
        let context = OpenObserveContext.mockWith(userInfo: nil, accountInfo: nil)

        // When
        let sharedContext = SharedContext(ooContext: context)

        // Then
        XCTAssertNil(sharedContext.userId)
        XCTAssertNil(sharedContext.accountId)
    }

    func testInitializationWithOpenObserveContext_withCompleteContext() throws {
        // Given
        let context = OpenObserveContext.mockWith(
            userInfo: UserInfo(
                id: "user-789"
            ),
            accountInfo: AccountInfo(
                id: "account-999"
            )
        )

        // When
        let sharedContext = SharedContext(ooContext: context)

        // Then
        XCTAssertEqual(sharedContext.userId, "user-789")
        XCTAssertEqual(sharedContext.accountId, "account-999")
    }
}
