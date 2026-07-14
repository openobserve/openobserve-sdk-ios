/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal

final class ReadWriteLockTests: XCTestCase {
    @ReadWriteLock
    var value: Int = 0

    func testLockMutation() {
        var lock: ReadWriteLock? = ReadWriteLock(wrappedValue: 0)

        // swiftlint:disable opening_brace
        callConcurrently(
            closures: [
                { _ = lock?.wrappedValue },
                { self._value.mutate { $0 = 1 } },
                { lock?.wrappedValue = 1 }
            ],
            iterations: 1_000
        )

        XCTAssertEqual(value, 1)
        // swiftlint:enable opening_brace

        lock = nil
    }

    func testValueIsReadableAndWritableConcurrently() {
        // swiftlint:disable opening_brace
        callConcurrently(
            closures: [
                { _ = self.value },
                { self._value.mutate { $0 += 1 } }
            ],
            iterations: 1_000
        )

        XCTAssertEqual(value, 1_000)
        // swiftlint:enable opening_brace
    }
}
