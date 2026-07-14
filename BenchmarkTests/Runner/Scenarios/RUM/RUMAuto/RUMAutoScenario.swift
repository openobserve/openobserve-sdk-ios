/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveCore
import OpenObserveRUM
import SwiftUI

struct RUMAutoScenario: Scenario {
    var initialViewController: UIViewController {
        UIHostingController(rootView: RUMAutoContentView())
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
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                swiftUIViewsPredicate: DefaultSwiftUIRUMViewsPredicate(),
                swiftUIActionsPredicate: DefaultSwiftUIRUMActionsPredicate(isLegacyDetectionEnabled: true)
            )
        )

        RUMMonitor.shared().addAttribute(forKey: "scenario", value: "RUMAuto")
    }
}
