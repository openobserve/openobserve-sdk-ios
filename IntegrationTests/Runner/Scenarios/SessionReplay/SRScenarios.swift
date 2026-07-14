/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import UIKit
import OpenObserveRUM
import OpenObserveSessionReplay
import OpenObserveCore

/// Scenario which navigates between multiple views in navigation view controller.
/// - Each view is tracked with RUM and SR.
/// - Each view is presented still for a short moment of time.
/// - Default privacy level is set to `.mask`.
final class SRMultipleViewsRecordingScenario: TestScenario {
    static let storyboardName = "SRMultipleViewsRecordingScenario"

    func configureFeatures() {
        var rumConfig = RUM.Configuration(applicationID: "rum-application-id")
        rumConfig.uiKitViewsPredicate = DefaultUIKitRUMViewsPredicate()
        rumConfig.customEndpoint = Environment.serverMockConfiguration()?.rumEndpoint
        RUM.enable(with: rumConfig)

        var srConfig = SessionReplay.Configuration(replaySampleRate: 100)
        srConfig.touchPrivacyLevel = .show
        srConfig.customEndpoint = Environment.serverMockConfiguration()?.srEndpoint
        SessionReplay.enable(with: srConfig)
    }
}
