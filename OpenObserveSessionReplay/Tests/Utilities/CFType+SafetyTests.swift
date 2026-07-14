/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import Foundation
import XCTest
@testable import OpenObserveSessionReplay

class CFTypeSafetyTests: XCTestCase {
    func testInvalidCGColorValueIsSanitized() {
        let valid: CGColor = UIColor.red.cgColor
        XCTAssertEqual(valid, valid.safeCast)

        let string: Any = "invalid CGColor value"
        let invalid = string as! CGColor
        XCTAssertNil(invalid.safeCast)
    }
}
#endif
