/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import UIKit
import OpenObserveCore
import OpenObserveTrace

internal class CSRootViewController: UIViewController {
    @IBAction func startCore(_ sender: UIButton) {
        appConfiguration.initializeSDK()
    }

    @IBAction func stopCore(_ sender: UIButton) {
        appConfiguration.deinitializeSDK()
    }
}
