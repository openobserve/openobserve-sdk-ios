/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

extension BinaryImage: AnyMockable, RandomMockable {
    public static func mockAny() -> BinaryImage {
        return .mockWith()
    }

    public static func mockRandom() -> BinaryImage {
        return BinaryImage(
            libraryName: .mockRandom(),
            uuid: .mockRandom(),
            architecture: .mockRandom(),
            isSystemLibrary: .mockRandom(),
            loadAddress: .mockRandom(),
            maxAddress: .mockRandom()
        )
    }

    public static func mockWith(
        libraryName: String = .mockAny(),
        uuid: String = .mockAny(),
        architecture: String = .mockAny(),
        isSystemLibrary: Bool = .mockAny(),
        loadAddress: String = .mockAny(),
        maxAddress: String = .mockAny()
    ) -> BinaryImage {
        return BinaryImage(
            libraryName: libraryName,
            uuid: uuid,
            architecture: architecture,
            isSystemLibrary: isSystemLibrary,
            loadAddress: loadAddress,
            maxAddress: maxAddress
        )
    }
}
