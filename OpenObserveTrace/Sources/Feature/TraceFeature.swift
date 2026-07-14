/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

internal final class TraceFeature: OpenObserveRemoteFeature {
    static let name = "tracing"

    let requestBuilder: FeatureRequestBuilder
    var messageReceiver: FeatureMessageReceiver { contextReceiver }

    let tracer: OpenObserveTracer
    let contextReceiver: ContextMessageReceiver

    /// Allows overriding certain performance presets if needed. Default is nil.
    let performanceOverride: PerformancePresetOverride?

    init(
        in core: OpenObserveCoreProtocol,
        configuration: Trace.Configuration
    ) {
        self.requestBuilder = TracingRequestBuilder(
            customIntakeURL: configuration.customEndpoint,
            telemetry: core.telemetry
        )

        let sampleRate = configuration.debugSDK ? 100 : configuration.sampleRate
        let samplingProvider = SamplerProvider(sampleRate: sampleRate)

        self.contextReceiver = ContextMessageReceiver(samplerProvider: samplingProvider)
        self.tracer = OpenObserveTracer(
            core: core,
            samplingProvider: samplingProvider,
            tags: configuration.tags ?? [:],
            traceIDGenerator: configuration.traceIDGenerator,
            spanIDGenerator: configuration.spanIDGenerator,
            dateProvider: configuration.dateProvider,
            loggingIntegration: TracingWithLoggingIntegration(
                core: core,
                service: configuration.service,
                networkInfoEnabled: configuration.networkInfoEnabled
            ),
            spanEventBuilder: SpanEventBuilder(
                service: configuration.service,
                networkInfoEnabled: configuration.networkInfoEnabled,
                eventsMapper: configuration.eventMapper,
                bundleWithRUM: configuration.bundleWithRumEnabled,
                telemetry: core.telemetry
            )
        )
        self.performanceOverride = nil

        // Send configuration telemetry:
        core.telemetry.configuration(useTracing: true)
    }
}
