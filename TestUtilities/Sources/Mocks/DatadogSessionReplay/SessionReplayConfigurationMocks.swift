/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

extension SessionReplayPrivacyLevel: AnyMockable, RandomMockable {
    public static func mockAny() -> Self {
        .allow
    }

    public static func mockRandom() -> Self {
        [.allow, .mask, .maskUserInput].randomElement()!
    }
}

extension TextAndInputPrivacyLevel: AnyMockable, RandomMockable {
    public static func mockAny() -> Self {
        .maskSensitiveInputs
    }

    public static func mockRandom() -> Self {
        [.maskAll, .maskAllInputs, .maskSensitiveInputs].randomElement()!
    }
}

extension ImagePrivacyLevel: AnyMockable, RandomMockable {
    public static func mockAny() -> Self {
        .maskNonBundledOnly
    }

    public static func mockRandom() -> Self {
        [.maskNonBundledOnly, .maskAll, .maskNone].randomElement()!
    }
}

extension TouchPrivacyLevel: AnyMockable, RandomMockable {
    public static func mockAny() -> Self {
        .show
    }

    public static func mockRandom() -> Self {
        [.show, .hide].randomElement()!
    }
}
