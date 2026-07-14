/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal
@testable import OpenObserveCore

extension OpenObserveContextProvider: AnyMockable {
    public static func mockAny() -> Self { .mockWith() }

    public static func mockWith(context: OpenObserveContext = .mockAny()) -> Self {
        .init(context: context)
    }
}
