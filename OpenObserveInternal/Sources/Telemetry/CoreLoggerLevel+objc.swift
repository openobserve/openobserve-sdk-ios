/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

@objc(DDCoreLoggerLevel)
@_spi(objc)
public enum objc_CoreLoggerLevel: Int {
    case none
    case debug
    case warn
    case error
    case critical
}
