/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import OpenObserveInternal

/// Enable iOS Crash Reporting and Error Tracking to get comprehensive crash reports and
/// error trends with Real User Monitoring. With this feature, you can access:
///
/// - Aggregated iOS crash dashboards and attributes
/// - Symbolicated iOS crash reports
/// - Trend analysis with iOS error tracking
///
/// In order to symbolicate your stack traces, find and upload your .dSYM files to OpenObserve.
/// Then, verify your configuration by running a test crash and restarting your application.
///
/// Your crash reports appear in [Error Tracking](https://app.openobserve.ai/rum/error-tracking).
public final class CrashReporting {
    /// Initializes the OpenObserve Crash Reporter using the default
    /// `KSCrash` plugin.
    public static func enable(in core: OpenObserveCoreProtocol = CoreRegistry.default) {
        enable(with: try KSCrashPlugin(telemetry: core.telemetry), in: core)
    }

    /// Initializes the OpenObserve Crash Reporter with a custom Crash Reporting Plugin.
    ///
    /// The custom plugin will be responsible for:
    /// - Provide crash report
    /// - Store context data associated with crashes
    /// - Provide backtraces
    public static func enable(with plugin: @autoclosure () throws -> CrashReportingPlugin, in core: OpenObserveCoreProtocol = CoreRegistry.default) {
        do {
            // To ensure the correct registration order between Core and Features,
            // the entire initialization flow is synchronized on the main thread.
            try runOnMainThreadSync {
                try enableOrThrow(with: plugin(), in: core)
            }
        } catch let error {
            consolePrint("\(error)", .error)
        }
    }

    internal static func enableOrThrow(with plugin: CrashReportingPlugin, in core: OpenObserveCoreProtocol) throws {
        guard !(core is NOPOpenObserveCore) else {
            throw ProgrammerError(
                description: "OpenObserve SDK must be initialized before calling `CrashReporting.enable()`."
            )
        }

        let contextProvider = CrashContextCoreProvider()

        let reporter = CrashReportingFeature(
            crashReportingPlugin: plugin,
            crashContextProvider: contextProvider,
            sender: MessageBusSender(core: core),
            messageReceiver: contextProvider,
            telemetry: core.telemetry
        )

        try core.register(feature: reporter)

        if let backtraceReporter = plugin.backtraceReporter {
            try core.register(backtraceReporter: backtraceReporter)
        }

        reporter.sendCrashReportIfFound()

        core.telemetry.configuration(trackErrors: true)
    }
}

/// Enable iOS Crash Reporting and Error Tracking to get comprehensive crash reports and
/// error trends with Real User Monitoring. With this feature, you can access:
///
/// - Aggregated iOS crash dashboards and attributes
/// - Symbolicated iOS crash reports
/// - Trend analysis with iOS error tracking
///
/// In order to symbolicate your stack traces, find and upload your .dSYM files to OpenObserve.
/// Then, verify your configuration by running a test crash and restarting your application.
///
/// Your crash reports appear in [Error Tracking](https://app.openobserve.ai/rum/error-tracking).
@available(swift, obsoleted: 1)
@objc(DDCrashReporter)
public final class objc_CrashReporting: NSObject {
    /// Initializes the OpenObserve Crash Reporter.
    @objc
    public static func enable() {
        CrashReporting.enable()
    }
}
