/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation

internal struct ExposureEvent: Equatable, Codable {
    struct Identifier: Equatable, Codable {
        let key: String
    }

    struct Subject: Equatable, Codable {
        let id: String
        let attributes: [String: AnyValue]
    }

    let timestamp: Int64
    let allocation: Identifier
    let flag: Identifier
    let variant: Identifier
    let subject: Subject
}
