/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import UIKit

import OpenObserveCore
import OpenObserveRUM
import OpenObserveSessionReplay

import CatalogUIKit

struct SessionReplayScenario: Scenario {
    var initialViewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: CatalogUIKit.bundle)
        return storyboard.instantiateInitialViewController()!
    }

    func instrument(with info: AppInfo) {
        OpenObserve.initialize(
            with: .benchmark(info: info),
            trackingConsent: .granted
        )

        RUM.enable(
            with: RUM.Configuration(
                applicationID: info.applicationID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate()
            )
        )

        SessionReplay.enable(
            with: SessionReplay.Configuration(
                replaySampleRate: 100,
                textAndInputPrivacyLevel: .maskSensitiveInputs,
                imagePrivacyLevel: .maskNone,
                touchPrivacyLevel: .show,
                featureFlags: [.heatmaps: true]
            )
        )

        RUMMonitor.shared().addAttribute(forKey: "scenario", value: "SessionReplay")
    }
}
