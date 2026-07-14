/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

extension AccountConfigurationContext: AnyMockable, RandomMockable {
    public static func mockAny() -> Self { mockWith() }

    public static func mockRandom() -> Self {
        .init(
            id: .mockRandom(),
            name: .mockRandom()
        )
    }

    public static func mockWith(
        id: String = .mockAny(),
        name: String? = .mockAny()
    ) -> Self {
        .init(
            id: id,
            name: name
        )
    }
}
