Pod::Spec.new do |s|
  s.name         = "TestUtilities"
  s.version      = "0.1.0-alpha.1"
  s.summary      = "OpenObserve Testing Utilities. This module is for internal testing and should not be published."

  s.homepage     = "https://www.openobserve.ai"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  # openobserve: upstream listed four named Datadog engineers here. The rebrand rewrote
  # their addresses to @openobserve.ai, fabricating contact details for real people who do
  # not work here and never consented — inaccurate personal data, and an implied endorsement
  # that does not exist. Restoring the upstream addresses would be no better: it would imply
  # those engineers author or maintain THIS fork and would route our support mail to their
  # inboxes. `authors` is package-MAINTAINER metadata, and the maintainer is OpenObserve.
  # Apache-2.0 attribution is untouched and lives where the licence requires it: the per-file
  # "developed at Datadog" headers, the Copyright lines, NOTICE and LICENSE (see
  # scripts/openobserve/check-attribution.mjs). Matches the Android POM <developer> block.
  s.authors            = { "OpenObserve" => "info@openobserve.ai" }

  s.swift_version = '5.9'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'

  s.source = { :git => "https://github.com/openobserve/openobserve-sdk-ios.git", :tag => s.version.to_s }

  s.pod_target_xcconfig = {
    'ENABLE_TESTING_SEARCH_PATHS'=>'YES'
  }

  s.framework = 'XCTest'

  s.source_files = [
    "TestUtilities/Sources/**/*.swift"
  ]

  s.dependency 'OpenObserveCore'
  s.dependency 'OpenObserveInternal'
  s.dependency 'OpenObserveLogs'
  s.dependency 'OpenObserveRUM'
  s.dependency 'OpenObserveSessionReplay'
  s.dependency 'OpenObserveTrace'
  s.dependency 'OpenObserveCrashReporting'
  s.dependency 'OpenObserveWebViewTracking'

end