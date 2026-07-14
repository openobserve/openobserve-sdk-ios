/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

@testable import OpenObserveLogs
@testable import OpenObserveRUM
@testable import OpenObserveTrace
@testable import OpenObserveInternal

extension OpenObserveCoreProxy {
    public func waitAndReturnSpanMatchers(file: StaticString = #file, line: UInt = #line) throws -> [SpanMatcher] {
        return try waitAndReturnEventsData(ofFeature: TraceFeature.name)
            .map { eventData in try SpanMatcher.fromJSONObjectData(eventData) }
    }

    public func waitAndReturnSpanEvents(file: StaticString = #file, line: UInt = #line) -> [SpanEvent] {
        return waitAndReturnEvents(ofFeature: TraceFeature.name, ofType: SpanEventsEnvelope.self)
            .map { envelope in
                precondition(envelope.spans.count == 1, "Only expect one `SpanEvent` per envelope")
                return envelope.spans[0]
            }
    }
}

extension OpenObserveCoreProxy {
    public func waitAndReturnLogMatchers(file: StaticString = #file, line: UInt = #line) throws -> [LogMatcher] {
        return try waitAndReturnEventsData(ofFeature: LogsFeature.name)
            .map { data in try LogMatcher.fromJSONObjectData(data) }
    }
}

extension OpenObserveCoreProxy {
    public func waitAndReturnRUMEventMatchers(file: StaticString = #file, line: UInt = #line) throws -> [RUMEventMatcher] {
        return try waitAndReturnEventsData(ofFeature: RUMFeature.name)
            .map { data in try RUMEventMatcher.fromJSONObjectData(data) }
    }
}
