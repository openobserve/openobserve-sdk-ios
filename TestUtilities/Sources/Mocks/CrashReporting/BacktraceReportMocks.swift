/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import OpenObserveInternal

extension BacktraceReport: AnyMockable, RandomMockable {
    public static func mockAny() -> BacktraceReport {
        return .mockWith()
    }

    public static func mockRandom() -> BacktraceReport {
        return BacktraceReport(
            stack: .mockRandom(),
            threads: .mockRandom(),
            binaryImages: .mockRandom(),
            wasTruncated: .mockRandom()
        )
    }

    public static func mockWith(
        stack: String = .mockAny(),
        threads: [DDThread] = .mockAny(),
        binaryImages: [BinaryImage] = .mockAny(),
        wasTruncated: Bool = .mockAny()
    ) -> BacktraceReport {
        return BacktraceReport(
            stack: stack,
            threads: threads,
            binaryImages: binaryImages,
            wasTruncated: wasTruncated
        )
    }
}
