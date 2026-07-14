/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)

import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
internal enum GraphicsFilter {
    case colorMultiply(Color._Resolved)
    case unknown
}

#endif
