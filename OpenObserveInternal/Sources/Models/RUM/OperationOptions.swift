/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

public protocol OperationOptions {}

@objc(DDOperationOptions)
@objcMembers
@_spi(objc)
public class objc_OperationOptions: NSObject {
    public var swiftType: OperationOptions

    init(swiftType: OperationOptions) {
        self.swiftType = swiftType
    }
}
