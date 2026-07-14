/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

#if os(iOS)
import UIKit
import OpenObserveInternal

internal struct UIImageResource {
    private let image: UIImage
    private let tintColor: UIColor?

    internal init(image: UIImage, tintColor: UIColor?) {
        self.image = image
        self.tintColor = tintColor
    }
}

extension UIImageResource: Resource {
    var mimeType: String {
        "image/png"
    }

    func calculateIdentifier() -> String {
        tintColor.map { image.dd.identifier + $0.dd.identifier } ?? image.dd.identifier
    }

    func calculateData() -> Data {
        image.dd.pngData(tintColor: tintColor) ?? Data()
    }
}
#endif
