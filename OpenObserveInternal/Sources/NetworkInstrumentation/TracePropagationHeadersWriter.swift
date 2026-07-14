/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-2020 OpenObserve, Inc.
 */

import Foundation

/// Write interface for a custom carrier
public protocol TracePropagationHeadersWriter {
    var traceHeaderFields: [String: String] { get }

    func write(traceContext: TraceContext)
}
