/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// Publishes the application vesrion value to receiver.
internal final class ApplicationVersionPublisher: ContextValuePublisher {
    let initialValue: String

    private var receiver: ContextValueReceiver<String>?

    var version: String {
        didSet { receiver?(version) }
    }

    init(version: String) {
        self.initialValue = version
        self.version = version
    }

    func publish(to receiver: @escaping ContextValueReceiver<String>) {
        self.receiver = receiver
    }

    func cancel() {
        receiver = nil
    }
}
