/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal
import OpenObserveCore

/// Test info reads configuration from `Info.plist`.
///
/// The expected format is as follow:
///
///     <dict>
///         <key>OpenObserveConfiguration</key>
///         <dict>
///             <key>ClientToken</key>
///             <string>$(CLIENT_TOKEN)</string>
///             <key>ApplicationID</key>
///             <string>$(RUM_APPLICATION_ID)</string>
///             <key>Environment</key>
///             <string>$(DD_ENV)</string>
///             <key>Site</key>
///             <string>$(DD_SITE)</string>
///         </dict>
///     </dict>
struct TestInfo {
    let clientToken: String
    let applicationID: String
    let site: OpenObserveSite
    let env: String
}

extension TestInfo {
    init(bundle: Bundle = .main) throws {
        guard
            let obj = bundle.object(forInfoDictionaryKey: "OpenObserveConfiguration") as? [String: String],
            let clientToken = obj["ClientToken"],
            let applicationID = obj["ApplicationID"],
            let site = obj["Site"].flatMap(OpenObserveSite.init(rawValue:)),
            let env = obj["Environment"]
        else {
            throw ProgrammerError(description: "Missing required Info.plist keys")
        }

        self = .init(clientToken: clientToken, applicationID: applicationID, site: site, env: env)
    }
}

extension TestInfo {
    static var empty: Self {
        .init(
            clientToken: "",
            applicationID: "",
            site: .us1,
            env: "e2e"
        )
    }
}

extension OpenObserve.Configuration {
    static func e2e(info: TestInfo) -> Self {
        .init(
            clientToken: info.clientToken,
            env: info.env,
            site: info.site,
            uploadFrequency: .frequent
        )
    }
}
