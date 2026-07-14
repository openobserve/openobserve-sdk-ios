/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

// swiftlint:disable identifier_name
internal extension objc_OTTracer {
    var dd: objc_Tracer? { warnIfCannotCast(value: self) }
}
internal extension objc_OTSpan {
    var dd: objc_SpanObjc? { warnIfCannotCast(value: self) }
}
internal extension objc_OTSpanContext {
    var dd: objc_SpanContextObjc? { warnIfCannotCast(value: self) }
}
// swiftlint:enable identifier_name
