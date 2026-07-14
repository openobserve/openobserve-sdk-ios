/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

/// Publishes the current `AccountInfo` value to receiver.
internal final class AccountInfoPublisher: ContextValuePublisher {
    let initialValue: AccountInfo? = nil

    private var receiver: ContextValueReceiver<AccountInfo?>?

    var current: AccountInfo? = nil {
        didSet { receiver?(current) }
    }

    func publish(to receiver: @escaping ContextValueReceiver<AccountInfo?>) {
        self.receiver = receiver
    }

    func cancel() {
        receiver = nil
    }
}
