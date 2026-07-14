/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

public struct ProfilingOptions: OperationOptions {
    // The profiling sample rate for operations. Must be a value between `0` and `100`.
    public let sampleRate: SampleRate

    public init(sampleRate: SampleRate) {
        self.sampleRate = sampleRate
    }
}
