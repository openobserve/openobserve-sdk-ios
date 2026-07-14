/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

/// The set of messages that can be transmitted on the Features message bus.
public enum FeatureMessage {
    /// A custom payload message.
    case payload(Any)

    /// A web-view message.
    ///
    /// Represent a Browser SDK event sent through the JS bridge.
    case webview(WebViewMessage)

    /// A core context message.
    ///
    /// The core will send updated context through the bus. Do not send new context values
    /// from a Feature or Integration.
    case context(OpenObserveContext)

    /// A telemetry message.
    ///
    /// The core can send telemetry data coming from all Features.
    case telemetry(TelemetryMessage)
}
