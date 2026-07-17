Pod::Spec.new do |s|
  s.name         = "OpenObserveProfiling"
  s.version      = "0.1.0-alpha.1"
  s.summary      = "Official OpenObserve Profiling module of the Swift SDK."
  
  s.homepage     = "https://www.openobserve.ai"
  s.social_media_url   = "https://twitter.com/openobserve"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  s.authors            = "OpenObserve, Inc."

  s.swift_version = '5.9'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'

  s.source = { :git => "https://github.com/openobserve/openobserve-sdk-ios.git", :tag => s.version.to_s }
  
  s.source_files = ["OpenObserveProfiling/Sources/**/*.swift",
                    "OpenObserveProfiling/Mach/**/*.{h,c,cpp}"]
  
  s.private_header_files = ["OpenObserveProfiling/Mach/**/*.h"]

  s.preserve_paths = "OpenObserveProfiling/Mach/include/module.modulemap"

  s.dependency 'OpenObserveInternal', s.version.to_s

  # Configure C++ compilation
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/OpenObserveProfiling/Mach/include'
  }

end
