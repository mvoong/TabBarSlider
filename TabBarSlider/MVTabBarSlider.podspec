Pod::Spec.new do |s|
  s.name         = "MVTabBarSlider"
  s.version      = "0.1.0"
  s.summary      = "A UIKit category selector control with natural auto selection"

  s.description  = <<-DESC
                   A longer description of TabBarSlider in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/TabBarSlider"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author       = { "Michael Voong" => "michael@voo.ng" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "http://github.com/mvoong/TabBarSlider.git", :tag => "0.1.0" }
  s.source_files  = "Classes", "Classes/**/*.{swift}"
  s.dependency "PureLayout"
end
