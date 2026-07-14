/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import UIKit

/// A type observing the application object and finding the most relevant window for session replay recording.
internal protocol AppWindowObserver {
    var relevantWindow: UIWindow? { get }
}
#endif
