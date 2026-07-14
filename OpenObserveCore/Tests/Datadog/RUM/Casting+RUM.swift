/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

@testable import OpenObserveRUM

internal extension RUMMonitorProtocol {
    var dd: Monitor { self as! Monitor }
}
