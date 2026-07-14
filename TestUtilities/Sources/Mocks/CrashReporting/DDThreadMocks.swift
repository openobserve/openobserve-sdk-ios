/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

extension DDThread: AnyMockable, RandomMockable {
    public static func mockAny() -> DDThread {
        return .mockWith()
    }

    public static func mockRandom() -> DDThread {
        return DDThread(
            name: .mockRandom(),
            stack: .mockRandom(),
            crashed: .mockRandom(),
            state: .mockRandom()
        )
    }

    public static func mockWith(
        name: String = .mockAny(),
        stack: String = .mockAny(),
        crashed: Bool = .mockAny(),
        state: String? = .mockAny()
    ) -> DDThread {
        return DDThread(
            name: name,
            stack: stack,
            crashed: crashed,
            state: state
        )
    }
}
