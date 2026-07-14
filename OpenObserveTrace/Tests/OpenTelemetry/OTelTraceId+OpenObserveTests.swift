/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
import OpenTelemetryApi

@testable import OpenObserveTrace

class OTelTraceIdOpenObserveTests: XCTestCase {
    func testToOpenObserve_onlyHigherOrderBitsAreConsidered() {
        let otelId = TraceId.random()
        let ddId = otelId.toOpenObserve()
        XCTAssertEqual(otelId.idLo, ddId.idLo)
        XCTAssertEqual(otelId.idHi, ddId.idHi)
    }
}
