/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

@objc(DDProfilingOptions)
@objcMembers
@_spi(objc)
public final class objc_ProfilingOptions: objc_OperationOptions {
    public init(sampleRate: Float) {
        super.init(swiftType: ProfilingOptions(sampleRate: sampleRate))
    }
}
