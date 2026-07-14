/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
@_spi(Internal)
import OpenObserveInternal

/// An entry point to OpenObserve Trace feature.
public enum Trace {
    /// Enables OpenObserve Trace feature.
    ///
    /// After Trace is enabled, use `Tracer.shared(in:)` to collect spans.
    ///
    /// - Parameters:
    ///   - configuration: Configuration of the feature.
    ///   - core: The instance of OpenObserve SDK to enable Trace in (global instance by default).
    public static func enable(
        with configuration: Trace.Configuration = .init(), in core: OpenObserveCoreProtocol = CoreRegistry.default
    ) {
        do {
            // To ensure the correct registration order between Core and Features,
            // the entire initialization flow is synchronized on the main thread.
            try runOnMainThreadSync {
                try enableOrThrow(with: configuration, in: core)
            }
        } catch let error {
            consolePrint("\(error)", .error)
        }
    }

    internal static func enableOrThrow(
        with configuration: Trace.Configuration, in core: OpenObserveCoreProtocol
    ) throws {
        guard !(core is NOPOpenObserveCore) else {
            throw ProgrammerError(
                description: "OpenObserve SDK must be initialized before calling `Trace.enable(with:)`."
            )
        }

        // Register Trace feature:
        let trace = TraceFeature(in: core, configuration: configuration)
        try core.register(feature: trace)

        // If `URLSession` tracking is configured, register `URLSessionHandler` to enable distributed tracing:
        if let urlSessionTracking = configuration.urlSessionTracking {
            let firstPartyHosts: FirstPartyHosts
            let traceContextInjection: TraceContextInjection
            let tracingSampleRate: SampleRate

            switch urlSessionTracking.firstPartyHostsTracing {
            case let .trace(hosts, sampleRate, injection):
                tracingSampleRate = sampleRate
                firstPartyHosts = FirstPartyHosts(hosts)
                traceContextInjection = injection
            case let .traceWithHeaders(hostsWithHeaders, sampleRate, injection):
                tracingSampleRate = sampleRate
                firstPartyHosts = FirstPartyHosts(hostsWithHeaders)
                traceContextInjection = injection
            }

            let urlSessionHandler = TracingURLSessionHandler(
                tracer: trace.tracer,
                contextReceiver: trace.contextReceiver,
                samplingRate: configuration.debugSDK ? 100 : tracingSampleRate,
                firstPartyHosts: firstPartyHosts,
                traceContextInjection: traceContextInjection,
                telemetry: core.telemetry,
                redactedStatusCodes: urlSessionTracking.redactedStatusCodes
            )

            try core.register(urlSessionHandler: urlSessionHandler)

            // Enable automatic network tracking as the foundation for duration breakdown.
            // Distributed tracing benefits from duration breakdown (enabled separately via URLSessionInstrumentation.enableDurationBreakdown)
            // to capture accurate timing from URLSessionTaskMetrics.
            try URLSessionInstrumentation.enableOrThrow(with: nil, in: core)
        }

        core.set(context: TraceCoreContext.ActiveSpanProvider { [weak tracer = trace.tracer] in
            tracer?.activeSpan?.context.dd.map {
                ActiveSpanContext(
                    traceID: $0.traceID,
                    activeSpanID: $0.spanID,
                    samplingPriority: $0.samplingDecision.samplingPriority,
                    samplingMechanismType: $0.samplingDecision.decisionMaker,
                    samplingRate: $0.sampleRate
                )
            }
        })
    }
}
