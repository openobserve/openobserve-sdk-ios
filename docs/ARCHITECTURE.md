# SDK Architecture

## Module Structure

The SDK is a **modular monorepo**:

```
OpenObserveInternal (shared protocols, types — Foundation only, no external deps)
    ├── OpenObserveCore (initialization, storage, upload)
    ├── OpenObserveLogs
    ├── OpenObserveTrace
    ├── OpenObserveRUM
    ├── OpenObserveSessionReplay
    ├── OpenObserveCrashReporting
    ├── OpenObserveWebViewTracking
    ├── OpenObserveFlags
    ├── OpenObserveProfiling
    └── TestUtilities (test-only, shared mocks/matchers)
```

### Module Boundaries

- Feature modules MUST NOT import each other
- Only `OpenObserveCore` orchestrates feature lifecycles
- `OpenObserveInternal` is the ONLY allowed place for shared types — it defines interfaces; `OpenObserveCore` provides concrete implementations
- Platform support: iOS 12.0+, tvOS 12.0+, macOS 12.6+, watchOS 7.0+ (limited modules), visionOS 1.0+ (limited modules)

### Call Site Synchronization

**When modifying code in feature modules (Logs, Trace, RUM, etc.), you MUST check if any corresponding call sites in `OpenObserveCore` and `OpenObserveInternal` need to be updated.**

Common oversights:
- Forgetting to update how `OpenObserveCore` registers the feature
- Forgetting to update shared types in `OpenObserveInternal`
- Forgetting to update manual data encoders (`SpanEventEncoder`, `LogEventEncoder`, ...) — new attributes won't be reported
- Forgetting to update ObjC bridges
- Forgetting to update `.pbxproj` files when adding, removing, or moving files

**Always search for usages across the entire codebase before considering a change complete.**

## Data Flow

### RUM Event Emission Pipeline

1. App calls public API (e.g., `RUMMonitor.shared().startView(...)`)
2. `Monitor` (concrete `RUMMonitorProtocol` implementation) creates a `RUMCommand` with timestamp, attributes, user ID
3. Command is enqueued to `FeatureScope` (async serial queue in `OpenObserveCore`)
4. `FeatureScope` invokes scope hierarchy: `RUMApplicationScope.process()` → `RUMSessionScope.process()` → `RUMViewScope.process()`
5. Each scope decides whether to accept, transform, or reject the command (returns `Bool` — `true` = scope stays open, `false` = scope is closed and removed from parent)
6. If valid, scope serializes to RUM event JSON and calls `writer.write(data:)`
7. `Writer` appends data to in-memory buffer or disk file
8. `DataUploadWorker` periodically reads batches of events from disk
9. `RequestBuilder` wraps batch in HTTP POST to OpenObserve intake
10. `HTTPClient` sends request; on success files are deleted; on failure backoff/retry applies

### Storage Pipeline

```
Feature writes event → AsyncWriter → FileWriter → FilesOrchestrator → disk file
                                                                         ↓
DataUploadWorker (periodic) → DataReader → RequestBuilder → HTTPClient → OpenObserve backend
```

- File-based storage in Application Support sandbox — no database
- Directory structure: `[AppSupport]/OpenObserve/[site]/[feature]/`
- Format: JSON for events, binary TLV encoding for compact storage
- Optional encryption via `DataEncryption` protocol
- Caching explicitly disabled at URLSession level (ephemeral config, `urlCache = nil`)
- Key-value storage: `FeatureDataStore` for feature-specific persistent data

### Feature Registration Lifecycle

1. App calls `OpenObserve.initialize(with:trackingConsent:)` — creates `OpenObserveCore` instance
2. `OpenObserveCore` is registered in `CoreRegistry` (singleton lookup)
3. App calls feature-specific `enable()` (e.g., `RUM.enable(with:in:)`)
4. Feature creates its plugin (e.g., `RUMFeature`) and registers with core
5. Core allocates storage directory and upload worker for the feature
6. Feature can now write events and receive messages via the bus

### State Management (Context)

`OpenObserveContext` is the central context object containing device info, app state, user info, network state, etc. It is built by `OpenObserveContextProvider` from multiple `ContextValuePublisher` instances that subscribe to system notifications and update context in real-time. Context is passed to every scope during command processing and attached to events before writing.

## Key Abstractions

| Abstraction | Purpose | Examples |
|-------------|---------|----------|
| **Feature** | Represents a module (RUM, Logs, Trace). Conforms to `OpenObserveFeature` or `OpenObserveRemoteFeature`. | `RUMFeature`, `LogsFeature` |
| **Scope** | Hierarchical state container. Implements `process(command:context:writer:)` returning `Bool` (`true` = scope stays open, `false` = scope is closed and removed). | `RUMApplicationScope`, `RUMSessionScope`, `RUMViewScope` |
| **Command** | User action or system event triggering state changes. Struct with timestamp, attributes. | `RUMStartViewCommand`, `RUMAddUserActionCommand` |
| **Storage & Upload** | Persist events and batch-transmit to backend. | `FeatureStorage`, `FileWriter`, `DataUploadWorker` |
| **Context Provider** | Publishes system/app state changes. Implements `ContextValuePublisher`. | `UserInfoPublisher`, `NetworkConnectionInfoPublisher` |
| **Message Bus** | Inter-feature pub/sub communication. Protocol (`FeatureMessageReceiver`) in `OpenObserveInternal/Sources/MessageBus/`; concrete `MessageBus` in `OpenObserveCore`. | `MessageBus`, `FeatureMessageReceiver` |

## Key Protocols

| Protocol | Purpose | Location |
|----------|---------|----------|
| `OpenObserveCoreProtocol` | Central injectable core interface | `OpenObserveInternal/Sources/OpenObserveCoreProtocol.swift` |
| `OpenObserveFeature` | Base protocol for feature modules | `OpenObserveInternal/Sources/OpenObserveFeature.swift` |
| `OpenObserveRemoteFeature` | Extension adding `requestBuilder` for features that upload data | `OpenObserveInternal/Sources/OpenObserveFeature.swift` |
| `FeatureScope` | Provides features with event writing, context, and storage | `OpenObserveInternal/Sources/OpenObserveCoreProtocol.swift` |
| `FeatureMessageReceiver` | Receives inter-feature messages via the bus | `OpenObserveInternal/Sources/MessageBus/` |
| `ContextValuePublisher` | Publishes context value changes | `OpenObserveCore/Sources/Core/Context/ContextValuePublisher.swift` |
| `DataEncryption` | Optional encryption for on-disk data | `OpenObserveCore/Sources/Core/Storage/DataEncryption.swift` |

## Message Bus

### Message Types

Inter-feature communication uses `FeatureMessage` (defined in `OpenObserveInternal/Sources/MessageBus/FeatureMessage.swift`):

| Case | When to use |
|------|------------|
| `.context(OpenObserveContext)` | **Shared state that changes over time.** Broadcast automatically on every context update. Receivers extract what they need from `OpenObserveContext.additionalContext`. |
| `.payload(Any)` | **One-off events or commands.** Sender explicitly calls `core.send(message: .payload(...))`. Receiver downcasts to the expected type. |
| `.webview(WebViewMessage)` | Browser SDK events from the JS bridge (logs, RUM, telemetry, session replay records). |
| `.telemetry(TelemetryMessage)` | SDK internal telemetry (debug, error, configuration, metric, usage). |

### `.context` Pattern — Reading Shared State

Use this when a feature needs to track another feature's evolving state (e.g., current RUM view, session sampling decision). Context is propagated automatically — no explicit sends required.

**How it works:**
1. A feature sets its context via `featureScope.set(context: { RUMCoreContext(...) })` — this updates `OpenObserveContext.additionalContext`.
2. Any context change triggers `OpenObserveCore` to broadcast `.context(ooContext)` to every registered feature.
3. Receivers extract what they need: `context.additionalContext(ofType: RUMCoreContext.self)`.

**Canonical example** — Session Replay's `RUMContextReceiver` (`OpenObserveSessionReplay/Sources/Feature/RUMContextReceiver.swift`):

```swift
func receive(message: FeatureMessage, from core: OpenObserveCoreProtocol) -> Bool {
    guard case let .context(context) = message else { return false }
    let new = context.additionalContext(ofType: RUMCoreContext.self)
    if new != previous { onNew?(new); previous = new }
    return true
}
```

Other `.context` receivers: Trace's `ContextMessageReceiver`, `NetworkContextCoreProvider`, `CrashContextCoreProvider`, `WatchdogTerminationMonitor`, `ContextSharingTransformer`.

### `.payload` Pattern — One-Off Events

Use this for discrete events that one feature sends and another consumes — crash reports, error forwarding, flag evaluations.

**Examples:**
- `RemoteLogger` sends `.payload(RUMErrorMessage)` → RUM's `ErrorMessageReceiver` adds a RUM error
- `CrashReportSender` sends `.payload(Crash)` → RUM's `CrashReportReceiver` writes crash error events
- `FatalErrorContextNotifier` sends `.payload(RUMViewEvent)` → `CrashContextCoreProvider` persists the last view for crash reports

### `CombinedFeatureMessageReceiver` — Ordering Matters

`CombinedFeatureMessageReceiver` uses `contains(where:)` — it **short-circuits** after the first receiver returns `true`. Receivers later in the list will not see the message. This is intentional for deduplication but means **ordering of receivers within a feature matters**.

Note: `MessageBus.send()` does NOT short-circuit across features — every registered feature receives every message.

### `RUMCoreContext`

Defined in `OpenObserveInternal/Sources/Models/RUM/RUMCoreContext.swift`. Key fields: `applicationID`, `sessionID`, `viewID`, `userActionID`, `viewServerTimeOffset`, `sessionSampler`. Conforms to `AdditionalContext` (key: `"rum"`) and `Equatable`.

Set by `Monitor.swift` after each command via `featureScope.set(context:)`. Consumed by any receiver that calls `context.additionalContext(ofType: RUMCoreContext.self)`.

## Error Handling Strategy

The SDK must **never throw exceptions** to customer code:

- **NOP implementations**: `NOPMonitor`, `NOPOpenObserveCore` silently accept all API calls when SDK is not initialized or a feature is disabled.
- **Validation at boundaries**: Invalid input is logged via `DD.logger` and ignored.
- **Upload backoff**: Upload failures trigger exponential backoff and retry. Network errors are logged but never crash.
- **User callback safety**: Exceptions in user-provided callbacks (e.g., event mappers) are caught and logged — original event is sent.

## Thread Safety Rules

- **`@ReadWriteLock`**: Property wrapper for concurrent read, exclusive write access. Use for shared mutable state.
- **Serial queues**: Scope processing uses serial dispatch queues (`FeatureScope` is serial).
- **No `DispatchQueue.main.sync`**: Forbidden — prevents deadlocks.
- **NSLock exception**: `NSLock` is used in method swizzling code (`OpenObserveInternal/Sources/Swizzling/`, `OpenObserveInternal/Sources/NetworkInstrumentation/`) where low-level synchronization is required — do not refactor those.
- **No thread spawning**: SDK uses system background queues (`qos: .utility`), never creates threads.

## HTTP Upload Details

- **Auth**: Client token passed as `O2-API-KEY` header
- **Custom headers**: `O2-EVP-ORIGIN`, `O2-EVP-ORIGIN-VERSION`, `O2-REQUEST-ID`
- **Formats**: JSON, NDJSON (batches), multipart/form-data (Session Replay, crashes)
- **Compression**: Gzip (`Content-Encoding: gzip`)
- **Endpoints by site**: `.us1` → `browser-intake-openobserve.ai`, `.eu1` → `browser-intake-openobserve.eu`, etc.
- **Header builder**: `OpenObserveInternal/Sources/Upload/URLRequestBuilder.swift`
- **Site definitions**: `OpenObserveInternal/Sources/Context/OpenObserveSite.swift`

## Dependencies

- **KSCrash 2.5.0**: Crash detection and reporting (`OpenObserveCrashReporting`)
- **opentelemetry-swift-core 2.3.0+**: OpenTelemetry API for distributed tracing (`OpenObserveTrace`).

Avoid adding new dependencies unless absolutely necessary (small footprint principle).

## Extension Libraries

- **OpenObserve Integration for Apollo iOS**: https://github.com/openobserve/openobserve-sdk-ios-apollo-interceptor — extracts GraphQL Operation information from requests to let OpenObserveRUM enrich GraphQL RUM Resources
