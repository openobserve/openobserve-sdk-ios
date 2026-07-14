/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import TestUtilities
import OpenObserveInternal

@testable import OpenObserveLogs
@testable import OpenObserveTrace

class DDSpanTests: XCTestCase {
    // MARK: - Sending Span Logs

    func testWhenLoggingSpanEvent_itWritesLogToLogOutput() throws {
        let core = OpenObserveCoreProxy()
        defer { XCTAssertNoThrow(try core.flushAndTearDown()) }

        Logs.enable(in: core)
        Trace.enable(in: core)

        // Given
        let tracer = Tracer.shared(in: core)
        let span = tracer.startSpan(operationName: .mockAny())

        // When
        let log1Fields = mockRandomAttributes()
        span.log(fields: log1Fields)

        let log2Fields = mockRandomAttributes()
        span.log(fields: log2Fields)

        // Then
        let logs: [LogEvent] = core.waitAndReturnEvents(ofFeature: LogsFeature.name, ofType: LogEvent.self)
        XCTAssertEqual(logs.count, 2, "It should send 2 logs")
        DDAssertJSONEqual(
            AnyEncodable(logs[0].attributes.userAttributes),
            AnyEncodable(log1Fields)
        )
        DDAssertJSONEqual(
            AnyEncodable(logs[1].attributes.userAttributes),
            AnyEncodable(log2Fields)
        )
    }
}
