/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import Foundation

/// Produces `ViewTreeSnapshot` describing the user interface in current app.
internal protocol ViewTreeSnapshotProducer {
    /// Produces the snapshot of a view tree.
    /// - Parameter context: the context of Recorder from the moment of requesting snapshot
    /// - Returns: the snapshot or `nil` if it cannot be taken.
    /// - Throws: can throw an `InternalError` if any problem occurs.
    func takeSnapshot(with context: Recorder.Context) throws -> ViewTreeSnapshot?
}
#endif
