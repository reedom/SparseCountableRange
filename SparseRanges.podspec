#
# Be sure to run `pod lib lint SparseRanges.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SparseRanges'
  s.version          = '0.1.0'
  s.summary          = 'A collection of CountableRange objects that expresses a sparsed range.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A collection of CountableRange objects that can express a sparsed range.
                       DESC

  s.homepage         = 'https://github.com/reedom/SparseRanges'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HANAI tohru' => 'tohru@reedom.com' }
  s.source           = { :git => 'https://github.com/HANAI tohru/SparseRanges.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'

  s.source_files = 'SparseRanges/Classes/**/*'

  # s.resource_bundles = {
  #   'SparseRanges' => ['SparseRanges/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
