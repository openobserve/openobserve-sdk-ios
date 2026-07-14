/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal
import OpenTelemetryApi

internal struct DDNoopGlobals {
    static let tracer = DDNoopTracer()
    static let span = DDNoopSpan()
    static let context = DDNoopSpanContext()
}

internal class DDNoopTracer: OTTracer, OpenTelemetryApi.Tracer {
    var activeSpan: OTSpan? = nil

    private func warn() {
        DD.logger.warn(
            """
            The `OpenObserveTracer.shared()` was called but `OpenObserveTracer` is not initialised. Configure the `OpenObserveTracer` before invoking the feature:
                OpenObserveTracer.initialize()
            See https://openobserve.ai/docs/tracing/setup_overview/setup/ios
            """
        )
    }

    func extract(reader: OTFormatReader) -> OTSpanContext? {
        warn()
        return DDNoopGlobals.context
    }

    func inject(spanContext: OTSpanContext, writer: OTFormatWriter) {
        warn()
    }

    func startSpan(operationName: String, references: [OTReference]?, tags: [String: Encodable]?, startTime: Date?) -> OTSpan {
        warn()
        return DDNoopGlobals.span
    }

    func startRootSpan(operationName: String, tags: [String: Encodable]?, startTime: Date?) -> OTSpan {
        warn()
        return DDNoopGlobals.span
    }

    func startRootSpan(operationName: String, tags: [String: any Encodable]?, startTime: Date?, customSampleRate: SampleRate?) -> any OTSpan {
        warn()
        return DDNoopGlobals.span
    }

    // MARK: - Open Telemetry

    func spanBuilder(spanName: String) -> OpenTelemetryApi.SpanBuilder {
        warn()
        return NOPOTelSpanBuilder()
    }
}

internal struct DDNoopSpan: OTSpan {
    var context: OTSpanContext { DDNoopGlobals.context }
    func tracer() -> OTTracer { DDNoopGlobals.tracer }
    func setOperationName(_ operationName: String) {}
    func finish(at time: Date) {}
    func log(fields: [String: Encodable], timestamp: Date) {}
    func baggageItem(withKey key: String) -> String? { nil }
    func setBaggageItem(key: String, value: String) {}
    func setTag(key: String, value: Encodable) {}
    @discardableResult
    func setActive() -> OTSpan { self }
}

internal struct DDNoopSpanContext: OTSpanContext {
    func forEachBaggageItem(callback: (String, String) -> Bool) {}
}
