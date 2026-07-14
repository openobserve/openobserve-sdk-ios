/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import Foundation
import OpenTelemetryApi
import OpenObserveInternal

extension OpenTelemetryApi.TraceId {
    /// Converts OpenTelemetry `TraceId` to OpenObserve `TraceID`.
    /// - Returns: OpenObserve `TraceID` with only higher order bits considered.
    func toOpenObserve() -> TraceID {
        return .init(idHi: self.idHi, idLo: self.idLo)
    }
}
