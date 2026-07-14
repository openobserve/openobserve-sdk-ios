/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import Foundation
@testable import OpenObserveSessionReplay

/// A queue that executes synchronously on the caller thread.
public class NoQueue: Queue {
    public init() {}
    public func run(_ block: @escaping () -> Void) {
        block()
    }
}
#endif
