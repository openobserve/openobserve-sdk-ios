/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import XCTest
import OpenObserveInternal
import TestUtilities

@_spi(Internal)
@testable import OpenObserveFlags

final class EvaluationLoggerMock: EvaluationLogging {
    var logEvaluationCalls: [(
        flagKey: String,
        assignment: FlagAssignment,
        context: FlagsEvaluationContext,
        error: String?
    )] = []

    func logEvaluation(
        for flagKey: String,
        assignment: FlagAssignment,
        evaluationContext: FlagsEvaluationContext,
        flagError: String?
    ) {
        logEvaluationCalls.append((flagKey, assignment, evaluationContext, flagError))
    }
}
