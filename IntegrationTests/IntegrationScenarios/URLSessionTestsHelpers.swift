/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import OpenObserveInternal
import HTTPServerMock

protocol URLSessionTestsHelpers {
    func getTraceID(from request: Request) -> TraceID?

    func getSpanID(from request: Request) -> SpanID?

    func isValid(sampleRate: Double) -> Bool

    func getRequestTags(_ request: Request) -> [String : String]
}

extension URLSessionTestsHelpers {
    /// Reads `traceparent`, formatted as `<version>-<trace-id>-<parent-id>-<trace-flags>`.
    private func getTraceparentComponents(from request: Request) -> [String]? {
        request.httpHeaders[W3CHTTPHeaders.traceparent]?
            .components(separatedBy: W3CHTTPHeaders.Constants.separator)
    }

    func getTraceID(from request: Request) -> TraceID? {
        guard let components = getTraceparentComponents(from: request), components.count > 1 else {
            return nil
        }
        return .init(components[1], representation: .hexadecimal)
    }

    func getSpanID(from request: Request) -> SpanID? {
        guard let components = getTraceparentComponents(from: request), components.count > 2 else {
            return nil
        }
        return .init(components[2], representation: .hexadecimal)
    }

    func isValid(sampleRate: Double) -> Bool { sampleRate >= 0 && sampleRate <= 1 }

    func getRequestTags(_ request: Request) -> [String : String] {
        // tags live in the `o2` list-member of `tracestate`, formatted as `o2=key1:value1;key2:value2`
        guard let tracestate = request.httpHeaders[W3CHTTPHeaders.tracestate] else {
            return [:]
        }

        let prefix = W3CHTTPHeaders.Constants.oo + "="
        guard tracestate.hasPrefix(prefix) else {
            return [:]
        }

        return tracestate
            .dropFirst(prefix.count)
            .components(separatedBy: W3CHTTPHeaders.Constants.tracestatePairSeparator)
            .reduce(into: [String: String]()) { result, pair in
                let elements = pair.components(separatedBy: W3CHTTPHeaders.Constants.tracestateKeyValueSeparator)
                if elements.count == 2 {
                    result[elements[0]] = elements[1]
                }
            }
    }
}
