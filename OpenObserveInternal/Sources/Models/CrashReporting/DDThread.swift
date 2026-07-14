/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// Unsymbolicated stack trace of a running thread.
public struct DDThread: Codable {
    /// The name of the thread, e.g. `"Thread 0"`
    public let name: String
    /// Unsymbolicated stack trace of the crash.
    public let stack: String
    /// If the thread was halted.
    public var crashed: Bool
    /// Thread state (CPU registers dump), only available for halted thread.
    public let state: String?

    public init(
        name: String,
        stack: String,
        crashed: Bool,
        state: String?
    ) {
        self.name = name
        self.stack = stack
        self.crashed = crashed
        self.state = state
    }

    // MARK: - Encoding

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case stack = "stack"
        case crashed = "crashed"
        case state = "state"
    }
}
