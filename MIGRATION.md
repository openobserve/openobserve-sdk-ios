# Migration Guide

This document outlines breaking changes and migration steps between major versions of the project.

## Migration from 2.x to 3.0

This section describes the main changes introduced in SDK `3.0` compared to `2.x`.

### Product Modules 

All SDK products (RUM, Trace, Logs, SessionReplay, and so on) remain modular and separated into distinct libraries. The main change is that the `OpenObserveObjc` module has been removed, with its contents integrated into the corresponding product modules.

The available `OpenObserve` libraries in 3.0 are:
- `OpenObserveCore`
- `OpenObserveCrashReporting`
- `OpenObserveLogs`
- `OpenObserveRUM`
- `OpenObserveSessionReplay`
- `OpenObserveTrace`
- `OpenObserveWebViewTracking`

<details>
  <summary>SPM</summary>

  ```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/openobserve/openobserve-sdk-ios", from: "3.0.0")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                .product(name: "OpenObserveCore", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveCrashReporting", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveLogs", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveRUM", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveSessionReplay", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveTrace", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveWebViewTracking", package: "openobserve-sdk-ios"),
            ]
        ),
    ]
)
  ```
</details>

<details>
  <summary>CocoaPods</summary>

  ```ruby
  pod 'OpenObserveCore'
  pod 'OpenObserveCrashReporting'
  pod 'OpenObserveLogs'
  pod 'OpenObserveRUM'
  pod 'OpenObserveSessionReplay'
  pod 'OpenObserveTrace'
  pod 'OpenObserveWebViewTracking'
  ```
</details>

<details>
  <summary>Carthage</summary>

  The `Cartfile` remains the same: 
  ```
  github "openobserve/openobserve-sdk-ios"
  ```

  In Xcode, you **must** link the following frameworks:
  ```
  OpenObserveCore.xcframework
  OpenObserveInternal.xcframework
  ```

  Then select the product modules you intend to use:
  ```
  OpenObserveCrashReporting.xcframework + CrashReporter.xcframework
  OpenObserveLogs.xcframework
  OpenObserveRUM.xcframework
  OpenObserveSessionReplay.xcframework
  OpenObserveTrace.xcframework
  OpenObserveWebViewTracking.xcframework
  ```
</details>

### SDK Configuration

The SDK should be initialized as early as possible in the app lifecycle, specifically in the `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)` callback. This ensures accurate measurement of all metrics, including application startup duration. For apps built with SwiftUI, use `@UIApplicationDelegateAdaptor` to access the `AppDelegate`.

```swift
import OpenObserveCore

OpenObserve.initialize(
    with: OpenObserve.Configuration(
        clientToken: "<client token>",
        env: "<environment>",
        service: "<service name>"
    ), 
    trackingConsent: .granted
)
```

**Note**: Initializing the SDK elsewhere (for example later during view loading) may result in inaccurate or missing telemetry, especially around app startup performance.

### RUM Product Changes

RUM View-level attributes are now automatically propagated to all related child events, including resources, user actions, errors, and long tasks. This ensures consistent metadata across events, making it easier to filter and correlate data on OpenObserve dashboards.

To manage View level attributes more effectively, new APIs were added:
- `Monitor.addViewAttribute(forKey:value:)`
- `Monitor.addViewAttributes(_:)`
- `Monitor.removeViewAttribute(forKey:)`
- `Monitor.removeViewAttributes(forKeys:)`

Other notable changes:
- All Objective-C RUM APIs are now included in `OpenObserveRUM`. The separate `OpenObserveObjc` module is no longer available.
- App Hangs and Watchdog terminations are no longer reported from app extensions or widgets.
- A new property `trackMemoryWarnings` was added to `RUM.Configuration` to report memory warnings as RUM Errors.

API changes:

|`2.x`|`3.0`|
|---|---|
|-|`RUM.Configuration.trackMemoryWarnings`|
|`RUMView(path:attributes:)`|`RUMView(name:attributes:isUntrackedModal:)`|
|-|`Monitor.addViewAttribute(forKey:value:)`|
|-|`Monitor.addViewAttributes(:)`|
|-|`Monitor.removeViewAttribute(forKey:)`|
|-|`Monitor.removeViewAttributes(forKeys:)`|

### Logs Product Changes

The Logs product no longer reports fatal errors. To enable Error Tracking for crashes, Crash Reporting must be enabled in conjunction with RUM.

Additionally, all Objective-C Logs APIs are now included in `OpenObserveLogs`. The separate `OpenObserveObjc` module is no longer available.

### APM Trace Product Changes

Trace sampling is now deterministic when used alongside RUM. It uses the RUM `session.id` to ensure consistent sampling.

Also:
- The `Trace.Configuration.URLSessionTracking.FirstPartyHostsTracing` configuration sets sampling for all requests by default and the trace context is injected only into sampled requests.
- All Objective-C Trace APIs are now included in `OpenObserveTrace`. The separate `OpenObserveObjc` module is no longer available.

**Note**: A similar configuration exists in `RUM.Configuration.URLSessionTracking.FirstPartyHostsTracing`.

### Session Replay Product Changes

Privacy settings are now more granular. The previous `defaultPrivacyLevel` parameter has been replaced with:
- `textAndInputPrivacyLevel`
- `imagePrivacyLevel`
- `touchPrivacyLevel`

Learn more about [privacy levels][1].

API changes:

|`2.x`|`3.0`|
|---|---|
|`SessionReplay.Configuration(replaySampleRate:defaultPrivacyLevel:startRecordingImmediately:customEndpoint:)`|`SessionReplay.Configuration(replaySampleRate:textAndInputPrivacyLevel:imagePrivacyLevel:touchPrivacyLevel:startRecordingImmediately:customEndpoint:featureFlags:)`|
|`SessionReplay.Configuration(replaySampleRate:defaultPrivacyLevel:startRecordingImmediately:customEndpoint:)`|`SessionReplay.Configuration(replaySampleRate:textAndInputPrivacyLevel:imagePrivacyLevel:touchPrivacyLevel:startRecordingImmediately:customEndpoint:featureFlags:)`|

### URLSession Instrumentation Changes

Legacy delegate types have been replaced by a unified instrumentation API:

|`2.x`|`3.0`|
|---|---|
|`OpenObserveURLSessionDelegate()`|`URLSessionInstrumentation.enable(with:)`|
|`DDURLSessionDelegate()`|`URLSessionInstrumentation.enable(with:)`|
|`DDNSURLSessionDelegate()`|`URLSessionInstrumentation.enable(with:)`|

## Migration from 1.x to 2.0

This section describes the main changes introduced in SDK `2.0` compared to `1.x`.

### Product Modules 

All relevant products (RUM, Trace, Logs, etc.) are now extracted into different modules. That allows you to integrate only what is needed into your application.

Whereas all products in version 1.x were contained in the single module, `OpenObserve`, you now need to adopt the following libraries:

- `OpenObserveCore`
- `OpenObserveLogs`
- `OpenObserveTrace`
- `OpenObserveRUM`
- `OpenObserveWebViewTracking`

These come in addition to the existing `OpenObserveCrashReporting` and `OpenObserveObjc`.

<details>
  <summary>SPM</summary>

  ```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/openobserve/openobserve-sdk-ios", from: "2.0.0")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                .product(name: "OpenObserveCore", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveLogs", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveTrace", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveRUM", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveCrashReporting", package: "openobserve-sdk-ios"),
                .product(name: "OpenObserveWebViewTracking", package: "openobserve-sdk-ios"),
            ]
        ),
    ]
)
  ```
</details>

<details>
  <summary>CocoaPods</summary>

  ```ruby
  pod 'OpenObserveCore'
  pod 'OpenObserveLogs'
  pod 'OpenObserveTrace'
  pod 'OpenObserveRUM'
  pod 'OpenObserveCrashReporting'
  pod 'OpenObserveWebViewTracking'
  pod 'OpenObserveObjc'
  ```
</details>

<details>
  <summary>Carthage</summary>

  The `Cartfile` stays the same: 
  ```
  github "openobserve/openobserve-sdk-ios"
  ```

  In Xcode, you **must** link the following frameworks:
  ```
  OpenObserveInternal.xcframework
  OpenObserveCore.xcframework
  ```

  Then you can select the modules you want to use:
  ```
  OpenObserveLogs.xcframework
  OpenObserveTrace.xcframework
  OpenObserveRUM.xcframework
  OpenObserveCrashReporting.xcframework + CrashReporter.xcframework
  OpenObserveWebViewTracking.xcframework
  OpenObserveObjc.xcframework
  ```
</details>

**Note**: In case of Crash Reporting and WebView Tracking usage it's also needed to add RUM and/or Logs modules to be able to report events to RUM and/or Logs respectively.

The `2.0` version of the iOS SDK also exposes unified API layouts and naming between iOS and Android SDKs and with other OpenObserve products.

### SDK Configuration Changes

Better SDK granularity is achieved with the extraction of different products into independent modules, therefore all product-specific configurations have been moved to their dedicated modules.

> The SDK must be initialized before enabling any product.

The Builder pattern of the SDK initialization has been removed in favor of structure definitions. The following example shows how a `1.x` initialization would translate in `2.0`.

**V1 Initialization**
```swift
import OpenObserve

OpenObserve.initialize(
    appContext: .init(),
    trackingConsent: .granted,
    configuration: OpenObserve.Configuration
        .builderUsing(
            clientToken: "<client token>",
            environment: "<environment>"
        )
        .set(serviceName: "<service name>")
        .build()
```
**V2 Initialization**
```swift
import OpenObserveCore

OpenObserve.initialize(
    with: OpenObserve.Configuration(
        clientToken: "<client token>",
        env: "<environment>",
        service: "<service name>"
    ), 
    trackingConsent: .granted
)
```

API changes:

|`1.x`|`2.0`|
|---|---|
|`OpenObserve.Configuration.Builder.set(serviceName:)`|`OpenObserve.Configuration.service`|
|`OpenObserve.Configuration.Builder.set(batchSize:)`|`OpenObserve.Configuration.batchSize`|
|`OpenObserve.Configuration.Builder.set(uploadFrequency:)`|`OpenObserve.Configuration.uploadFrequency`|
|`OpenObserve.Configuration.Builder.set(proxyConfiguration:)`|`OpenObserve.Configuration.proxyConfiguration`|
|`OpenObserve.Configuration.Builder.set(encryption:)`|`OpenObserve.Configuration.encryption`|
|`OpenObserve.Configuration.Builder.set(serverDateProvider:)`|`OpenObserve.Configuration.serverDateProvider`|
|`OpenObserve.AppContext(mainBundle:)`|`OpenObserve.Configuration.bundle`|

### Logs Product Changes

All the classes related to Logs are now strictly in the `OpenObserveLogs` module. You first need to enable the product:

```swift
import OpenObserveLogs

Logs.enable(with: Logs.Configuration(...))
```

Then, you can create a logger instance:

```swift
import OpenObserveLogs

let logger = Logger.create(
    with: Logger.Configuration(name: "<logger name>")
)
```

API changes:

|`1.x`|`2.0`|
|---|---|
|`OpenObserve.Configuration.Builder.setLogEventMapper(_:)`|`Logs.Configuration.eventMapper`|
|`OpenObserve.Configuration.Builder.set(loggingSamplingRate:)`|`Logs.Configuration.eventMapper`|
|`Logger.Builder.set(serviceName:)`|`Logger.Configuration.service`|
|`Logger.Builder.set(loggerName:)`|`Logger.Configuration.name`|
|`Logger.Builder.sendNetworkInfo(_:)`|`Logger.Configuration.networkInfoEnabled`|
|`Logger.Builder.bundleWithRUM(_:)`|`Logger.Configuration.bundleWithRumEnabled`|
|`Logger.Builder.bundleWithTrace(_:)`|`Logger.Configuration.bundleWithTraceEnabled`|
|`Logger.Builder.sendLogsToOpenObserve(false)`|`Logger.Configuration.remoteSampleRate = 0`|
|`Logger.Builder.set(ooReportingThreshold:)`|`Logger.Configuration.remoteLogThreshold`|
|`Logger.Builder.printLogsToConsole(_:, usingFormat)`|`Logger.Configuration.consoleLogFormat`|

### APM Trace Product Changes

All the classes related to Trace are now strictly in the `OpenObserveTrace` module. You first need to enable the product:

```swift
import OpenObserveTrace

Trace.enable(
    with: Trace.Configuration(...)
)
```

Then, you can access the shared Tracer instance:

```swift
import OpenObserveTrace

let tracer = Tracer.shared()
```

API changes:

|`1.x`|`2.0`|
|---|---|
|`OpenObserve.Configuration.Builder.trackURLSession(_:)`|`Trace.Configuration.urlSessionTracking`|
|`OpenObserve.Configuration.Builder.setSpanEventMapper(_:)`|`Trace.Configuration.eventMapper`|
|`OpenObserve.Configuration.Builder.set(tracingSamplingRate:)`|`Trace.Configuration.sampleRate`|
|`Tracer.Configuration.serviceName`|`Trace.Configuration.service`|
|`Tracer.Configuration.sendNetworkInfo`|`Trace.Configuration.networkInfoEnabled`|
|`Tracer.Configuration.globalTags`|`Trace.Configuration.tags`|
|`Tracer.Configuration.bundleWithRUM`|`Trace.Configuration.bundleWithRumEnabled`|
|`Tracer.Configuration.samplingRate`|`Trace.Configuration.sampleRate`|

### RUM Product Changes

All the classes related to RUM are now strictly in the `OpenObserveRUM` module. You will first need to enable the product:

```swift
import OpenObserveRUM

RUM.enable(
    with: RUM.Configuration(applicationID: "<RUM Application ID>")
)
```

Then, you can access the shared RUM monitor instance:

```swift
import OpenObserveRUM

let monitor = RUMMonitor.shared()
```

API changes:

|`1.x`|`2.0`|
|---|---|
|`OpenObserve.Configuration.Builder.trackURLSession(_:)`|`RUM.Configuration.urlSessionTracking`|
|`OpenObserve.Configuration.Builder.set(rumSessionsSamplingRate:)`|`RUM.Configuration.sessionSampleRate`|
|`OpenObserve.Configuration.Builder.onRUMSessionStart`|`RUM.Configuration.onSessionStart`|
|`OpenObserve.Configuration.Builder.trackUIKitRUMViews(using:)`|`RUM.Configuration.uiKitViewsPredicate`|
|`OpenObserve.Configuration.Builder.trackUIKitRUMActions(using:)`|`RUM.Configuration.uiKitActionsPredicate`|
|`OpenObserve.Configuration.Builder.trackRUMLongTasks(threshold:)`|`RUM.Configuration.longTaskThreshold`|
|`OpenObserve.Configuration.Builder.setRUMViewEventMapper(_:)`|`RUM.Configuration.viewEventMapper`|
|`OpenObserve.Configuration.Builder.setRUMResourceEventMapper(_:)`|`RUM.Configuration.resourceEventMapper`|
|`OpenObserve.Configuration.Builder.setRUMActionEventMapper(_:)`|`RUM.Configuration.actionEventMapper`|
|`OpenObserve.Configuration.Builder.setRUMErrorEventMapper(_:)`|`RUM.Configuration.errorEventMapper`|
|`OpenObserve.Configuration.Builder.setRUMLongTaskEventMapper(_:)`|`RUM.Configuration.longTaskEventMapper`|
|`OpenObserve.Configuration.Builder.setRUMResourceAttributesProvider(_:)`|`RUM.Configuration.urlSessionTracking.resourceAttributesProvider`|
|`OpenObserve.Configuration.Builder.trackBackgroundEvents(_:)`|`RUM.Configuration.trackBackgroundEvents`|
|`OpenObserve.Configuration.Builder.trackFrustrations(_:)`|`RUM.Configuration.frustrationsTracking`|
|`OpenObserve.Configuration.Builder.set(mobileVitalsFrequency:)`|`RUM.Configuration.vitalsUpdateFrequency`|
|`OpenObserve.Configuration.Builder.set(sampleTelemetry:)`|`RUM.Configuration.telemetrySampleRate`|

### Crash Reporting Changes

To enable Crash Reporting, make sure to also enable RUM and/or Logs.

```swift
import OpenObserveCrashReporting

CrashReporting.enable()
```

|`1.x`|`2.0`|
|---|---|
|`OpenObserve.Configuration.Builder.enableCrashReporting()`|`CrashReporting.enable()`|

### WebView Tracking Changes

To enable WebViewTracking, make sure to also enable RUM and/or Logs.

```swift
import WebKit
import OpenObserveWebViewTracking

let webView = WKWebView(...)
WebViewTracking.enable(webView: webView)
```

|`1.x`|`2.0`|
|---|---|
|`WKUserContentController.startTrackingOpenObserveEvents`|`WebViewTracking.enable(webView:)`|

### Using a Secondary Instance of the SDK

Previously OpenObserve SDK implemented a singleton and only one SDK instance could exist in the application process. This created obstacles for use-cases like the usage of the SDK by 3rd party libraries.

With version 2.0 we addressed this limitation:

* Now it is possible to initialize multiple instances of the SDK, associating them with a name.
* Many methods of the SDK can optionally take a SDK instance as an argument. If not provided, the call will be associated with the default (nameless) SDK instance.

Here is an example illustrating how to initialize a secondary core instance and enable products:

```swift
import OpenObserveCore
import OpenObserveRUM
import OpenObserveLogs
import OpenObserveTrace

let core = OpenObserve.initialize(
    with: configuration, 
    trackingConsent: trackingConsent, 
    instanceName: "my-instance"
)

RUM.enable(
    with: RUM.Configuration(applicationID: "<RUM Application ID>"),
    in: core
)

Logs.enable(in: core)

Trace.enable(in: core)
```

**Note**: The SDK instance name should have the same value between application runs. Storage paths for SDK events are associated with it.

Once initialized, you can retrieve the named SDK instance by calling `OpenObserve.sdkInstance(named: "<name>")` and use it for accessing the products.

```swift
import OpenObserveCore

let core = OpenObserve.sdkInstance(named: "my-instance")
```

#### Logs
```swift
import OpenObserveLogs

let logger = Logger.create(in: core)
```

#### Trace
```swift
import OpenObserveRUM

let monitor = RUMMonitor.shared(in: core)
```

#### RUM
```swift
import OpenObserveRUM

let monitor = RUMMonitor.shared(in: core)
```

[1]: /real_user_monitoring/session_replay/mobile/privacy_options?platform=ios