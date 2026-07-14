/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import Foundation
import OpenObserveInternal
import OpenTelemetryApi

/// The OpenObserve implementation of OpenTelemetry `TracerProvider`.
/// It takes the OpenObserve SDK instance as a dependency and returns the tracer from it.
///
/// Usage:
///
/// ```swift
/// import OpenTelemetryApi
/// import OpenObserveTrace
///
/// // Register the tracer provider
/// OpenTelemetry.registerTracerProvider(
///     tracerProvider: OTelTracerProvider()
/// )
///
/// // Get the tracer
/// let tracer = OpenTelemetry
///     .instance
///     .tracerProvider
///     .get(instrumentationName: "", instrumentationVersion: nil)
///
/// // Start a span
/// let span = tracer
///     .spanBuilder(spanName: "OperationName")
///     .startSpan()
/// ```
public class OTelTracerProvider: OpenTelemetryApi.TracerProvider {
    private weak var core: OpenObserveCoreProtocol?

    /// Creates a tracer provider with the given OpenObserve SDK instance.
    /// - Parameter core: the instance of OpenObserve SDK the Trace feature was enabled in (global instance by default)
    public init(in core: OpenObserveCoreProtocol = CoreRegistry.default) {
        self.core = core
    }

    /// Returns a tracer with the given instrumentation name and version.
    /// - Parameters:
    ///   - instrumentationName: the name of the instrumentation library, not the name of the instrumented library
    ///     Note: This is ignored, as the OpenObserve SDK works on concept of core.
    ///   - instrumentationVersion:  The version of the instrumentation library (e.g., "semver:1.0.0"). Optional
    ///     Note: This is ignored, as the OpenObserve SDK works on concept of core.
    ///   - schemaUrl: The schema url. Optional
    ///     Note: This is ignored in OpenObserve SDK.
    ///   - attributes: Attributes to be associated with spans created by this tracer. Optional.
    ///     Note: This is ignored by the OpenObserve SDK. To configure default tags for the tracer, use `Trace.Configuration`
    ///     passed to `Trace.enable()`.
    public func get(
        instrumentationName: String,
        instrumentationVersion: String?,
        schemaUrl: String?,
        attributes: [String: OpenTelemetryApi.AttributeValue]?
    ) -> any OpenTelemetryApi.Tracer {
        return get(instrumentationName: instrumentationName, instrumentationVersion: instrumentationVersion)
    }

    /// Returns a tracer with the given instrumentation name and version.
    /// - Parameters:
    ///   - instrumentationName: the name of the instrumentation library, not the name of the instrumented library
    ///     Note: This is ignored, as the OpenObserve SDK works on concept of core.
    ///   - instrumentationVersion:  The version of the instrumentation library (e.g., "semver:1.0.0"). Optional
    ///     Note: This is ignored, as the OpenObserve SDK works on concept of core.
    public func get(instrumentationName: String, instrumentationVersion: String?) -> OpenTelemetryApi.Tracer {
        do {
            guard !(core is NOPOpenObserveCore) else {
                throw ProgrammerError(
                    description: "OpenObserve SDK must be initialized and Trace feature must be enabled before calling `OTelTracerProvider.get(instrumentationName:instrumentationVersion:)`."
                )
            }
            guard let feature = core?.get(feature: TraceFeature.self) else {
                throw ProgrammerError(
                    description: "Trace feature must be enabled before calling `OTelTracerProvider.get(instrumentationName:instrumentationVersion:)`."
                )
            }

            // Send tracer API usage to telemetry
            core?.telemetry.configuration(tracerAPI: "OpenTelemetry", tracerAPIVersion: OpenTelemetry.version)

            return feature.tracer
        } catch {
            consolePrint("\(error)", .error)
            return DDNoopTracer()
        }
    }
}
