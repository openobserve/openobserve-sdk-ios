/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

#if canImport(WatchKit)
import WatchKit

extension OpenObserveExtension where ExtendedType == WKExtension {
    public static var shared: WKExtension {
        .shared()
    }
}

extension WKExtension: OpenObserveExtended { }
#endif
