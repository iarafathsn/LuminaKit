Pod::Spec.new do |s|
  s.name             = 'LuminaLoaderKit'
  s.module_name      = 'LuminaKit'
  s.version          = '2.0.0'
  s.summary          = 'An animated bubble loading indicator that traces the border of any view shape.'

  s.description      = <<-DESC
    LuminaKit provides a beautiful, animated bubble loading indicator for iOS.
    The bubble traces the border of any parent view shape — rectangles, circles,
    capsules, or custom paths. On iOS 26+, the bubble uses Apple's Liquid Glass
    material; on iOS 18–25, it falls back to a polished glass-morphic style.
    Supports both SwiftUI and UIKit.
  DESC

  s.homepage         = 'https://github.com/iarafathsn/LuminaKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Arafat Hossain' => '' }
  s.source           = { :git => 'https://github.com/iarafathsn/LuminaKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '18.0'
  s.swift_versions        = ['6.0']

  s.source_files = 'Sources/LuminaKit/**/*.{swift}'

  s.frameworks = 'UIKit', 'SwiftUI', 'CoreGraphics'
end
