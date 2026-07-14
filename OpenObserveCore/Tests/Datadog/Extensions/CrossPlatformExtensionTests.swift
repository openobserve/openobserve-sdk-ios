/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities
@_spi(Internal)
@testable import OpenObserveCore

class CrossPlatformExtensionTests: XCTestCase {
    func testSubscribe_receivesContextUpdates() throws {
        // Given
        let core = OpenObserveCoreProxy()
        CoreRegistry.register(default: core)
        defer { CoreRegistry.unregisterDefault() }

        @ReadWriteLock
        var lastContext: SharedContext?
        CrossPlatformExtension.subscribe { context in
            lastContext = context
        }

        // When
        core.setUserInfo(id: "user-123")
        core.setAccountInfo(id: "account-456")
        try core.flushAndTearDown()

        // Then
        // Verify we eventually get the user and account info
        XCTAssertEqual(lastContext?.userId, "user-123", "Should have user ID in final context")
        XCTAssertEqual(lastContext?.accountId, "account-456", "Should have account ID in final context")
    }
}
