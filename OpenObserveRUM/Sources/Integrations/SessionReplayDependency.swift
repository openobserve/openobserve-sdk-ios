/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

// MARK: - Extracting SR context from `OpenObserveContext`

extension OpenObserveContext {
    /// The value indicating if replay is being performed by Session Replay.
    var hasReplay: Bool? {
        additionalContext(ofType: SessionReplayCoreContext.HasReplay.self)?.value
    }

    /// The value of `[String: Int64]` that indicates number of records recorded for a given viewID.
    var recordsCountByViewID: [String: Int64] {
        additionalContext(ofType: SessionReplayCoreContext.RecordsCount.self)?.value ?? [:]
    }
}
