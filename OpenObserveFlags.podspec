Pod::Spec.new do |s|
  s.name         = "OpenObserveFlags"
  s.version      = "0.1.0-alpha.2"
  s.summary      = "Official OpenObserve Feature Flags module of the Swift SDK."

  s.homepage     = "https://www.openobserve.ai"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  s.authors            = "OpenObserve, Inc."

  s.swift_version = '5.9'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '7.0'

  s.source = { :git => "https://github.com/openobserve/openobserve-sdk-ios.git", :tag => s.version.to_s }

  s.source_files = "OpenObserveFlags/Sources/**/*.swift"

  s.dependency 'OpenObserveInternal', s.version.to_s

end
