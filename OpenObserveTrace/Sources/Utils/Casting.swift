/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

// swiftlint:disable identifier_name
internal extension OTSpanContext {
    var dd: DDSpanContext? { warnIfCannotCast(value: self) }
}
// swiftlint:enable identifier_name
