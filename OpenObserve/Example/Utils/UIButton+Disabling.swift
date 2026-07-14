/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import UIKit

extension UIButton {
    func disableFor(seconds: TimeInterval) {
        let completion = disableUntilCompletion()
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

    func disableUntilCompletion() -> () -> Void {
        let originalBackgroundColor = self.backgroundColor

        self.isEnabled = false
        self.backgroundColor = .systemGray

        return {
            self.isEnabled = true
            self.backgroundColor = originalBackgroundColor
        }
    }
}
