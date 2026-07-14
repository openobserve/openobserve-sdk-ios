/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveCore

class ObjcExceptionHandlerTests: XCTestCase {
    func testGivenNonThrowingCode_itDoesNotThrow() throws {
        var counter = 0
        try __dd_private_ObjcExceptionHandler.rethrow { counter += 1 }
        XCTAssertEqual(counter, 1)
    }

    func testGivenThrowingCode_itThrowsNSErrorToSwift() {
        let nsException = NSException(
            name: NSExceptionName(rawValue: "name"),
            reason: "reason",
            userInfo: ["user-info": "some"]
        )

        XCTAssertThrowsError(try __dd_private_ObjcExceptionHandler.rethrow { nsException.raise() }) { error in
            XCTAssertEqual((error as NSError).domain, "name")
            XCTAssertEqual((error as NSError).code, 0)
            XCTAssertEqual((error as NSError).userInfo as? [String: String], ["user-info": "some"])
        }
    }
}
