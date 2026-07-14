/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import CommonCrypto

/// Computes SHA256 for given `string`.
internal func sha256(_ string: String) -> String {
    guard let data = string.data(using: .utf8) else {
        return string
    }

    var digest: [UInt8] = Array(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = data.withUnsafeBytes { CC_SHA256($0.baseAddress, UInt32(data.count), &digest) }
    return digest
        .map({ byte in String(format: "%02x", byte) })
        .joined(separator: "")
}
