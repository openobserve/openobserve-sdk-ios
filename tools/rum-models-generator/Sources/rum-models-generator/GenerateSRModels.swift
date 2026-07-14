/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
 * Copyright 2019-Present OpenObserve, Inc.
 */

import Foundation
import CodeGeneration
import CodeDecoration

internal func generateSRSwiftModels(from schema: URL) throws -> String {
    let generator = ModelsGenerator()

    let template = OutputTemplate(
        header: """
            /*
             * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
             * This product includes software developed at OpenObserve (https://www.openobserve.ai/).
             * Copyright 2019-Present OpenObserve, Inc.
             */

            #if os(iOS)
            import OpenObserveInternal

            // This file was generated from JSON Schema. Do not modify it directly.

            // swiftlint:disable all

            internal protocol SRDataModel: Codable {}

            """,
        footer: """
        #endif
        """
    )
    let printer = SwiftPrinter(
        configuration: .init(
            accessLevel: .spi
        )
    )

    return try generator
        .generateCode(from: schema)
        .decorate(using: SRCodeDecorator())
        .sortTypes()
        .print(using: template, and: printer)
}

internal func generateSRObjcInteropModels(from schema: URL, skip: Set<String>) throws -> String {
    throw Exception.unimplemented("Generating Objc-interop code for Session Replay models is not supported.")
}
