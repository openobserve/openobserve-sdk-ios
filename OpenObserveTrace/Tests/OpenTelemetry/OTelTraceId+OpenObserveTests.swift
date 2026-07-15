/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal
import OpenTelemetryApi

@testable import OpenObserveTrace

class OTelTraceIdOpenObserveTests: XCTestCase {
    func testToOpenObserve_onlyHigherOrderBitsAreConsidered() {
        let otelId = TraceId.random()
        let ooId = otelId.toOpenObserve()
        XCTAssertEqual(otelId.idLo, ooId.idLo)
        XCTAssertEqual(otelId.idHi, ooId.idHi)
    }
}
