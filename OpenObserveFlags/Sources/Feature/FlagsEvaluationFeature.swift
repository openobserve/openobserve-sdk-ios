/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

internal struct FlagsEvaluationFeature: OpenObserveRemoteFeature {
    static let name = "flags-evaluation"

    let requestBuilder: any FeatureRequestBuilder
    let messageReceiver: any FeatureMessageReceiver
    let performanceOverride: PerformancePresetOverride?

    init(
        customIntakeURL: URL?,
        telemetry: Telemetry
    ) {
        requestBuilder = EvaluationRequestBuilder(
            customIntakeURL: customIntakeURL,
            telemetry: telemetry
        )
        messageReceiver = NOPFeatureMessageReceiver()
        performanceOverride = PerformancePresetOverride(maxObjectsInFile: 50)
    }
}
