/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// Provides current device time information.
public protocol DateProvider: Sendable {
    /// Current device time.
    ///
    /// A specific point in time, independent of any calendar or time zone.
    var now: Date { get }
}

/// Provides system date.
public struct SystemDateProvider: DateProvider {
    public init() { }

    /// Returns current system time.
    public var now: Date { .init() }
}
