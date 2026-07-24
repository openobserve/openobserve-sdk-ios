/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation

/// The type of the tracing header injected to requests.
///
/// - `b3` - Open Telemetry B3 [Single header](https://github.com/openzipkin/b3-propagation#single-headers).
/// - `b3multi` - Open Telemetry B3 [Multiple headers](https://github.com/openzipkin/b3-propagation#multiple-headers).
/// - `tracecontext` - W3C [Trace Context header](https://www.w3.org/TR/trace-context/#tracestate-header)
///
/// openobserve: upstream also offered its own proprietary propagator, which injected
/// `x-<upstream-vendor>-*` headers. It was REMOVED rather than renamed. These headers are
/// injected into the app's outbound requests to the CUSTOMER's own backend so that backend's
/// APM can link the RUM resource to a server-side trace — the reader is never OpenObserve's
/// intake, which speaks W3C `traceparent` and never parsed those headers at all. So the
/// propagator was only useful against an upstream-instrumented backend, and renaming its
/// headers to `o2-*` would not have rebranded it: no APM reads `o2-trace-id`, so it would have
/// emitted headers nothing understands and silently linked nothing.
/// Use `tracecontext` (W3C) — what OpenObserve actually reads — or `b3`.
public enum TracingHeaderType: Hashable {
    case b3
    case b3multi
    case tracecontext
}
