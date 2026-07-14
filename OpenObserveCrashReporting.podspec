Pod::Spec.new do |s|
  s.name         = "OpenObserveCrashReporting"
  s.version      = "3.11.0"
  s.summary      = "Official OpenObserve Crash Reporting SDK for iOS."

  s.homepage     = "https://www.openobserve.ai"
  s.social_media_url   = "https://twitter.com/openobserve"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  s.authors            = {
    "Maciek Grzybowski" => "maciek.grzybowski@openobserve.ai",
    "Maxime Epain" => "maxime.epain@openobserve.ai",
    "Ganesh Jangir" => "ganesh.jangir@openobserve.ai",
    "Maciej Burda" => "maciej.burda@openobserve.ai"
  }

  s.swift_version = '5.9'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '7.0'
  s.visionos.deployment_target = '1.0'

  s.source = { :git => 'https://github.com/openobserve/openobserve-sdk-ios.git', :tag => s.version.to_s }

  s.source_files = "OpenObserveCrashReporting/Sources/**/*.swift"
  s.dependency 'OpenObserveInternal', s.version.to_s
  s.dependency 'KSCrash/Recording', '2.5.0'
  s.dependency 'KSCrash/Filters', '2.5.0'

  s.resource_bundle = {
    "OpenObserveCrashReporting" => "OpenObserveCrashReporting/Resources/PrivacyInfo.xcprivacy"
  }
end
