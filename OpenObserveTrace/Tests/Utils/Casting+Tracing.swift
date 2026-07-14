/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

@testable import OpenObserveTrace

/*
 NOTE: The casting methods defined here do shadow the ones defined in `OpenObserve.Casting`.
 The difference is that here in tests we do force unwrapping (`as!`), whereas in `OpenObserve` we do `as?` with a warning.

 This is needed for expressiveness in testing, where i.e. `XCTAssertNil(span.context.dd?.parentID)` may give a false positive
 without considering if the `parentID` is `nil`. Using `span.context.dd.parentID` mitigates it.
 */

internal extension OTTracer {
    var dd: OpenObserveTracer { self as! OpenObserveTracer }
}

internal extension OTSpan {
    var dd: DDSpan { self as! DDSpan }
}

internal extension OTSpanContext {
    var dd: DDSpanContext { self as! DDSpanContext }
}
