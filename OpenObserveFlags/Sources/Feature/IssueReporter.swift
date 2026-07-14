/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

internal struct IssueReporter {
    let reportIssue: (_ message: String, _ file: StaticString, _ line: UInt) -> Void

    init(reportIssue: @escaping (_ message: String, _ file: StaticString, _ line: UInt) -> Void) {
        self.reportIssue = reportIssue
    }
}

extension IssueReporter {
    static var `default`: Self {
        `default`(isGracefulModeEnabled: true)
    }

    static func `default`(isGracefulModeEnabled: Bool) -> Self {
#if DEBUG
        isGracefulModeEnabled ? consolePrint : fatalError
#else
        coreLogger
#endif
    }

    private static let coreLogger = Self { message, _, _ in
        DD.logger.error(message)
    }

    private static let consolePrint = Self { message, _, _ in
        OpenObserveInternal.consolePrint("🔥 OpenObserve SDK usage error: \(message)", .error)
    }

    private static let fatalError = Self { message, file, line in
        Swift.fatalError(message, file: file, line: line)
    }
}

internal func reportIssue(
    _ message: @autoclosure () -> String,
    in core: (any OpenObserveCoreProtocol)?,
    file: StaticString = #file,
    line: UInt = #line
) {
    let issueReporter = core?.get(feature: FlagsFeature.self)?.issueReporter ?? .default
    issueReporter.reportIssue(message(), file, line)
}
