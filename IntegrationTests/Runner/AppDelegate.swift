/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import UIKit

var serviceName = "integration-scenarios-service-name"
var appConfiguration: AppConfiguration!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if Environment.isRunningUnitTests() {
            return false
        }

        appConfiguration = UITestsAppConfiguration()

        // Initialize OpenObserve SDK
        appConfiguration.initializeSDK()

        return true
    }
}

/// Bridges Swift objects to Objective-C.
@objcMembers
class SwiftGlobals: NSObject {
    class func currentTestScenario() -> Any? { appConfiguration.testScenario }
}
