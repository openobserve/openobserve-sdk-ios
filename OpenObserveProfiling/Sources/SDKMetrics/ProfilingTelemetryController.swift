/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

#if !os(watchOS)

internal final class ProfilingTelemetryController {
    /// The default sample rate for "Profiling App Launch" metric (20%),
    /// applied in addition to the Profiling feature sample rate (10% by default).
    static let defaultSampleRate: SampleRate = 20
    /// Telemetry endpoint for sending metrics.
    let telemetry: Telemetry
    /// The sample rate for "Profiling App Launch" metric.
    let sampleRate: SampleRate
    /// Metric with Profiling configurations.
    let configMetric: ConfigurationMetric

    init(
        sampleRate: SampleRate = ProfilingTelemetryController.defaultSampleRate,
        telemetry: Telemetry = NOPTelemetry(),
        configMetric: ConfigurationMetric = ConfigurationMetric()
    ) {
        self.sampleRate = sampleRate
        self.telemetry = telemetry
        self.configMetric = configMetric
    }

    /// Sends the telemetry metric.
    func send(metric: AppLaunchMetric) {
        guard var metricAttributes = metric.asMetricAttributes() else {
            telemetry.debug("Failed to compute attributes for '\(metric.metricName)'")
            return
        }
        metricAttributes.merge(configMetric.asMetricAttributes() ?? [:]) { $1 }

        telemetry.metric(name: metric.metricName, attributes: metricAttributes, sampleRate: sampleRate)
    }
}

#endif
