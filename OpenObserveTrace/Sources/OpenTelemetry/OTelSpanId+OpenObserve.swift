/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import Foundation
import OpenTelemetryApi
import OpenObserveInternal

extension OpenTelemetryApi.SpanId {
    /// Converts OpenTelemetry `SpanId` to OpenObserve `SpanID`.
    /// - Returns: OpenObserve `SpanID`.
    func toOpenObserve() -> SpanID {
        var data = Data(count: 8)
        self.copyBytesTo(dest: &data, destOffset: 0)
        let integerLiteral = UInt64(bigEndian: data.withUnsafeBytes { $0.load(as: UInt64.self) })
        return .init(integerLiteral: integerLiteral)
    }
}
