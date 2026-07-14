/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

internal final class ContextSharingTransformer: FeatureMessageReceiver, ContextValuePublisher {
    @ReadWriteLock
    private var sharedContext: SharedContext? = nil
    @ReadWriteLock
    private var receiver: ContextValueReceiver<SharedContext?>? = nil

    // MARK: - FeatureMessageReceiver

    func receive(message: FeatureMessage, from core: OpenObserveCoreProtocol) -> Bool {
        switch message {
        case .context(let context):
            let newContext = SharedContext(ooContext: context)
            sharedContext = newContext
            receiver?(newContext)
            return true
        default:
            return false
        }
    }

    // MARK: - ContextValuePublisher

    var initialValue: SharedContext? = nil

    func publish(to receiver: @escaping ContextValueReceiver<SharedContext?>) {
        self.receiver = receiver
        receiver(sharedContext)
    }

    func cancel() {
        receiver = nil
    }
}
