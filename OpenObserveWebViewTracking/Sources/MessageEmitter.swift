/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

/// Errors that can be thrown when parsing a WebView message
internal enum WebViewMessageError: Error, Equatable {
    case dataSerialization(message: String)
    case invalidMessage(description: String)
}

/// A type forwarding type-less messages received from OpenObserve Browser SDK to either `OpenObserveRUM` or `OpenObserveLogs`.
internal final class MessageEmitter: InternalExtension<WebViewTracking>.AbstractMessageEmitter {
    /// The core for events forwarding.
    private weak var core: OpenObserveCoreProtocol?
    /// Log events sampler.
    let logsSampler: Sampler

    init(
        logsSampler: Sampler,
        core: OpenObserveCoreProtocol
    ) {
        self.logsSampler = logsSampler
        self.core = core
    }

    /// Sends a bag of data to the message bus
    /// - Parameter body: The data to send, it must be parsable to `WebViewMessage`
    override func send(body: Any, slotId: String? = nil) {
        guard let core = core else {
            return DD.logger.debug("Core must not be nil when using WebViewTracking")
        }

        do {
            guard let body = body as? String else {
                throw WebViewMessageError.invalidMessage(description: String(describing: body))
            }

            guard let data = body.data(using: .utf8) else {
                throw WebViewMessageError.dataSerialization(message: body)
            }

            let decoder = JSONDecoder()
            let message = try decoder.decode(WebViewMessage.self, from: data)

            switch message {
            case .log:
                send(log: message, in: core)
            case .rum, .telemetry:
                send(rum: message, in: core)
            case let .record(event, view):
                send(record: event, view: view, slotId: slotId, in: core)
            }
        } catch {
            DD.logger.error("Encountered an error when receiving web view event", error: error)
            core.telemetry.error("Encountered an error when receiving web view event", error: error)
        }
    }

    private func send(log message: WebViewMessage, in core: OpenObserveCoreProtocol) {
        guard logsSampler.sample() else {
            return
        }

        core.send(message: .webview(message), else: {
            DD.logger.warn("A WebView log is lost because Logging is disabled in the SDK")
        })
    }

    private func send(rum message: WebViewMessage, in core: OpenObserveCoreProtocol) {
        core.send(message: .webview(message), else: {
            DD.logger.warn("A WebView RUM event is lost because RUM is disabled in the SDK")
        })
    }

    private func send(record event: WebViewMessage.Event, view: WebViewMessage.View, slotId: String?, in core: OpenObserveCoreProtocol) {
        var event = event
        // inject the slotId
        event["slotId"] = slotId

        core.send(message: .webview(.record(event, view)), else: {
            DD.logger.warn("A WebView Replay record is lost because Session Replay is disabled in the SDK")
        })
    }
}
