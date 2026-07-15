Pod::Spec.new do |s|
  s.name         = "TestUtilities"
  s.version      = "0.1.0-alpha.1"
  s.summary      = "OpenObserve Testing Utilities. This module is for internal testing and should not be published."

  s.homepage     = "https://www.openobserve.ai"
  s.social_media_url   = "https://twitter.com/openobserve"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  s.authors            = {
    "Maciek Grzybowski" => "maciek.grzybowski@openobserve.ai",
    "Maciej Burda" => "maciej.burda@openobserve.ai",
    "Maxime Epain" => "maxime.epain@openobserve.ai",
    "Ganesh Jangir" => "ganesh.jangir@openobserve.ai"
  }

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