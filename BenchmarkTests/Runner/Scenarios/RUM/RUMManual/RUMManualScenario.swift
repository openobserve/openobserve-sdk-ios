/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import SwiftUI

import OpenObserveCore
import OpenObserveRUM

struct RUMManualScenario: Scenario {
    var initialViewController: UIViewController {
        UIHostingController(rootView: RUMManualContentView())
    }

    func instrument(with info: AppInfo) {
        OpenObserve.initialize(
            with: .benchmark(info: info),
            trackingConsent: .granted
        )

        RUM.enable(
            with: RUM.Configuration(applicationID: info.applicationID)
        )

        RUMMonitor.shared().addAttribute(forKey: "scenario", value: "RUMManual")
    }
}
