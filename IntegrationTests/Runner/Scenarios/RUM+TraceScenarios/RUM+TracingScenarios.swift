/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveCore
import OpenObserveTrace
import OpenObserveLogs
import OpenObserveRUM

class RUMAndTracingURLSessionBaseScenario: URLSessionBaseScenario, TestScenario {
    static var storyboardName: String { "RUMAndTracingScenarios" }

    required override init() {
        super.init()
    }

    func configureFeatures() {
        var traceConfig = Trace.Configuration(sampleRate: 100)
        traceConfig.networkInfoEnabled = true
        traceConfig.customEndpoint = Environment.serverMockConfiguration()?.tracesEndpoint
        traceConfig.eventMapper = {
            var span = $0
            if span.tags[OTTags.httpUrl] != nil {
                span.tags[OTTags.httpUrl] = "redacted"
            }
            return span
        }

        Trace.enable(with: traceConfig)

        var rumConfig = RUM.Configuration(applicationID: "rum-application-id")
        rumConfig.customEndpoint = Environment.serverMockConfiguration()?.rumEndpoint
        rumConfig.uiKitViewsPredicate = DefaultUIKitRUMViewsPredicate()

        switch setup.instrumentationMethod {
        case .delegateUsingFeatureFirstPartyHosts:
            rumConfig.urlSessionTracking = .init(
                firstPartyHostsTracing: .trace(
                    hosts: [
                        customGETResourceURL.host!
                    ],
                    sampleRate: 0
                )
            )
        case .delegateWithAdditionalFirstPartyHosts:
            rumConfig.urlSessionTracking = .init(
                firstPartyHostsTracing: .trace(hosts: [], sampleRate: 100) // hosts will be set through `DDURLSessionDelegate`
            )
        }
        RUM.enable(with: rumConfig)
    }
}
