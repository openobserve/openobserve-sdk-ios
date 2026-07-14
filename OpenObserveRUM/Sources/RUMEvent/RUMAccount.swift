/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import OpenObserveInternal

extension RUMAccount {
    init?(context: OpenObserveContext) {
        guard let accountInfo = context.accountInfo else {
            return nil
        }

        self.init(accountInfo: accountInfo)
    }

    init(accountInfo: AccountInfo) {
        self.init(
            id: accountInfo.id,
            name: accountInfo.name,
            accountInfo: accountInfo.extraInfo
        )
    }
}
