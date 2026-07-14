/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

/// Publishes the user consent to receiver.
internal final class TrackingConsentPublisher: ContextValuePublisher {
    let initialValue: TrackingConsent

    private var receiver: ContextValueReceiver<TrackingConsent>?

    var consent: TrackingConsent {
        didSet { receiver?(consent) }
    }

    init(consent: TrackingConsent) {
        self.initialValue = consent
        self.consent = consent
    }

    func publish(to receiver: @escaping ContextValueReceiver<TrackingConsent>) {
        self.receiver = receiver
    }

    func cancel() {
        receiver = nil
    }
}
