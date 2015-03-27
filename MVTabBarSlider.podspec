Pod::Spec.new do |s|
  s.name         = "MVTabBarSlider"
  s.version      = "0.1.0"
  s.summary      = "A UIKit category selector control with natural auto selection"
  s.homepage     = "http://www.michaelvoong.com"
  s.license      = "MIT"
  s.author       = { "Michael Voong" => "michael@voo.ng" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/mvoong/TabBarSlider.git", :tag => "0.1.0" }
  s.source_files  = "Classes", "Classes/**/*.{swift}"
  s.dependency "PureLayout"
end
