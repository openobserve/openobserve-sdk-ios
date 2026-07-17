Pod::Spec.new do |s|
  s.name         = "OpenObserveRUM"
  s.version      = "0.1.0-alpha.1"
  s.summary      = "OpenObserve Real User Monitoring Module."

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

  s.source = { :git => "https://github.com/openobserve/openobserve-sdk-ios.git", :tag => s.version.to_s }

  s.source_files = ["OpenObserveRUM/Sources/**/*.swift"]

  s.resource_bundle = {
    "OpenObserveRUM" => "OpenObserveRUM/Resources/PrivacyInfo.xcprivacy"
  }

  s.dependency 'OpenObserveInternal', s.version.to_s

end
