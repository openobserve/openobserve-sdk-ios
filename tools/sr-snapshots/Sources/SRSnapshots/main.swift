/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at OpenObserve (https://www.openobserve.ai/).
* Copyright 2019-Present OpenObserve, Inc.
*/

import ArgumentParser
import SRSnapshotsCore

internal struct RootCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "CLI tool for managing Session Replay's snapshot files.",
        subcommands: [
            PushSnapshotsCommand.self,
            PullSnapshotsCommand.self,
        ]
    )
}

RootCommand.main()
