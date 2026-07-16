/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import OpenObserveInternal

/// List of NTP servers used to synchronize the SDK clock.
///
/// openobserve: upstream pointed these at the vendor's own registered *vendor zone* in the NTP
/// Pool Project (`[0-3].<upstream-vendor>.pool.ntp.org`). No SDK data travels over NTP (UDP/123
/// carries timestamps only) and that zone resolves to community pool servers, not to upstream
/// infrastructure — but every host running this SDK would still emit DNS lookups naming the
/// upstream vendor. Those are visible to enterprise DNS logging, proxies and packet capture, and
/// are enough for SDK-fingerprinting tools to report an OpenObserve app as embedding a
/// competitor's SDK. It also made our clock sync depend on a DNS zone a competitor controls.
///
/// The rebrand codemod could not reach these string literals: every upstream-identity rule
/// requires an uppercase letter or a suffix, and a bare lowercase hostname label matches none of
/// them. See scripts/openobserve/rename-map.json (now carries an explicit rule for this) and
/// check-no-datadog.sh (now fails on any upstream-named network host, not just file content).
///
/// INTERIM: neutral public anycast NTP — no registration, globally distributed. Note the NTP
/// Pool Project explicitly asks vendors NOT to hardcode the generic `pool.ntp.org` in
/// distributed software (that is precisely why upstream registered a vendor zone), so the
/// generic pool is not a correct destination for us either.
/// TODO(openobserve): register our own `openobserve.pool.ntp.org` vendor zone at
/// https://www.ntppool.org/vendors.html and point these there — the proper long-term fix.
///
/// Two independent providers, not one: a caller picks at random (`randomElement()`), and
/// upstream relied on 4 pool hosts for redundancy. Both are neutral public anycast services
/// and resolve identically on Android, so the two SDKs stay in sync. On failure the offset
/// falls back to `.zero` (device clock) — degraded ordering, never a crash.
public let OpenObserveNTPServers = [
    "time.cloudflare.com",
    "time.google.com"
]

/// Abstract the monotonic clock synchronized with the server using NTP.
public protocol ServerDateProvider {
    /// Start the clock synchronisation with NTP server.
    ///
    /// Calls the `completion` by passing it the server time offset when the synchronization succeeds.
    func synchronize(update: @escaping (TimeInterval) -> Void)
}

internal class OpenObserveNTPDateProvider: ServerDateProvider {
    let kronos: KronosClockProtocol

    init(kronos: KronosClockProtocol = KronosClock()) {
        self.kronos = kronos
    }

    func synchronize(update: @escaping (TimeInterval) -> Void) {
        kronos.sync(
            from: OpenObserveNTPServers.randomElement()!, // swiftlint:disable:this force_unwrapping
            first: { _, offset in
                update(offset)
            },
            completion: { now, offset in
                // Kronos only notifies for the first and last samples.
                // In case, the last sample does not return an offset, we calculate the offset
                // from the returned `now` parameter. The `now` parameter in this callback
                // is `Clock.now` and it can be either offset computed from prior samples or persisted
                // in user defaults from previous app session.
                if let offset = offset ?? now?.timeIntervalSinceNow {
                    update(offset)

                    let difference = (offset * 1_000).rounded() / 1_000
                    DD.logger.debug(
                        """
                        NTP time synchronization completed.
                        Server time will be used for signing events (\(difference)s difference with device time).
                        """
                    )
                } else {
                    update(0)

                    DD.logger.error(
                        """
                        NTP time synchronization failed.
                        Device time will be used for signing events.
                        """
                    )
                }
            }
        )

        // `Kronos.sync` first loads the previous state from the `UserDefaults` if any.
        // We can invoke `Clock.now` to retrieve the stored offset.
        if let offset = kronos.now?.timeIntervalSinceNow {
            update(offset)
        }
    }
}

/// The Server Offset Publisher provides updates on time offset between the
/// local time and one of the OpenObserve's NTP pool.
///
/// This publisher uses a modified version of the ``MobileNativeFoundation/Kronos``
/// see. https://github.com/MobileNativeFoundation/Kronos
///
/// The ``KronosClockPublisher/publish`` will start syncing with one of the pool
/// picked randomly from ``OpenObserveNTPServers``.
///
/// The time offset is defined in seconds.
internal final class ServerOffsetPublisher: ContextValuePublisher {
    /// The initial offset is 0.
    let initialValue: TimeInterval = .zero

    private var provider: ServerDateProvider?

    /// Creates a publisher using the given `KronosClock` implementation.
    ///
    /// - Parameter kronos: An object complying with `KronosClockProtocol`.
    init(provider: ServerDateProvider = OpenObserveNTPDateProvider()) {
        self.provider = provider
    }

    func publish(to receiver: @escaping ContextValueReceiver<TimeInterval>) {
        provider?.synchronize(update: receiver)
    }

    func cancel() {
        provider = nil
    }
}
