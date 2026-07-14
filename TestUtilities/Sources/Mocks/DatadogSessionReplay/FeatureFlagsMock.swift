/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)

import Foundation

@_spi(Internal)
@testable import OpenObserveSessionReplay

extension SessionReplay.Configuration.FeatureFlags {
    public static var allEnabled: Self {
        var flags: Self = [
            .swiftui: true,
            .heatmaps: true,
        ]

        if #available(iOS 13.0, tvOS 13.0, *) {
            flags[.layerTreeRecording] = true
        }

        return flags
    }
}

#endif
