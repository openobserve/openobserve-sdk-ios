/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

/// Defines whether the trace context should be injected into all requests or only sampled ones.
@objc(DDTraceContextInjection)
@_spi(objc)
public enum objc_TraceContextInjection: Int {
    internal var swiftType: OpenObserveInternal.TraceContextInjection {
        switch self {
        case .all:
            return .all
        case .sampled:
            return .sampled
        }
    }

    /// Injects trace context into all requests irrespective of the sampling decision.
    case all

    /// Injects trace context only into sampled requests.
    case sampled
}
