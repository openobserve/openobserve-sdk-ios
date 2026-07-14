/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest

@_spi(Internal)
@testable import OpenObserveSessionReplay
@testable import TestUtilities

class XoshiroTests: XCTestCase {
    func testRandomnValues() {
        let seed: XoshiroRandomNumberGenerator.StateType = (.mockRandom(), .mockRandom(), .mockRandom(), .mockRandom())
        var g1 = XoshiroRandomNumberGenerator(seed: seed)

        let a = g1.next()
        let b = g1.next()
        let c = g1.next()
        let d = g1.next()

        XCTAssert(a != b && a != c && a != d && b != c && b != d && c != d, "Technically, we *could* get a collision...")
    }

    func testDeterministicValues() {
        let seed: XoshiroRandomNumberGenerator.StateType = (.mockRandom(), .mockRandom(), .mockRandom(), .mockRandom())
        var g1 = XoshiroRandomNumberGenerator(seed: seed)
        var g2 = XoshiroRandomNumberGenerator(seed: seed)

        for _ in 0..<1_000 {
            XCTAssert(g1.next() == g2.next())
        }
    }
}
