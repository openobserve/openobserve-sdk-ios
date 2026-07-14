/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import Foundation
import OpenObserveInternal

internal class ResourcesFeature: OpenObserveRemoteFeature {
    static var name = "session-replay-resources"

    let messageReceiver: FeatureMessageReceiver = NOPFeatureMessageReceiver()
    let performanceOverride: PerformancePresetOverride?

    let requestBuilder: FeatureRequestBuilder

    init(
        core: OpenObserveCoreProtocol,
        configuration: SessionReplay.Configuration
    ) {
        self.requestBuilder = ResourceRequestBuilder(
            customUploadURL: configuration.customEndpoint,
            telemetry: core.telemetry
        )
        self.performanceOverride = PerformancePresetOverride(
            maxFileSize: SessionReplay.maxObjectSize,
            maxObjectSize: SessionReplay.maxObjectSize
        )
    }
}
#endif
