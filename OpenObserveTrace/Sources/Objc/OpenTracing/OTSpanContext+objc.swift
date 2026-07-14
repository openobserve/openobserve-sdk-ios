/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// Corresponds to: https://github.com/opentracing/opentracing-objc/blob/master/Pod/Classes/OTSpanContext.h
@objc(OTSpanContext)
@_spi(objc)
public protocol objc_OTSpanContext {
    func forEachBaggageItem(_ callback: (_ key: String, _ value: String) -> Bool)
}
