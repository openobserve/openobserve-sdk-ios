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

struct SessionReplayWebViewScenario: Scenario {
    func start(info: TestInfo) -> UIViewController {
        OpenObserve.initialize(
            with: .e2e(info: info),
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
                touchPrivacyLevel: .show
            )
        )

        RUMMonitor.shared().addAttribute(forKey: "scenario", value: "SessionReplayWebView")

        let storyboard = UIStoryboard(name: "SessionReplayWebView", bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
}
