/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

internal final class ContextSharingFeature: OpenObserveFeature {
    static var name: String = "_extension_context_sharing"

    var messageReceiver: FeatureMessageReceiver

    init(messageReceiver: FeatureMessageReceiver) {
        self.messageReceiver = messageReceiver
    }
}
