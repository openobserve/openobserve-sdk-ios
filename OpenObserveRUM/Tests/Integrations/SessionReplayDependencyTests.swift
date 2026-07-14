/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
@testable import OpenObserveRUM

class SessionReplayDependencyTests: XCTestCase {
    func testWhenSessionReplayIsConfigured_itReadsReplayBeingRecorded() throws {
        let hasReplay: Bool = .random()
        let recordsCountByViewID: [String: Int64] = [.mockRandom(): .mockRandom()]

        // When
        let context: OpenObserveContext = .mockWith(
            additionalContext: [
                SessionReplayCoreContext.HasReplay(value: hasReplay),
                SessionReplayCoreContext.RecordsCount(value: recordsCountByViewID)
            ]
        )

        // Then
        XCTAssertEqual(context.hasReplay, hasReplay)
        XCTAssertEqual(context.recordsCountByViewID, recordsCountByViewID)
    }

    func testWhenSessionReplayIsNotConfigured_itReadsNoSRBaggage() {
        // When
        let context: OpenObserveContext = .mockAny()

        // Then
        XCTAssertNil(context.hasReplay)
        XCTAssert(context.recordsCountByViewID.isEmpty)
    }
}
