# SparseRanges

[![CI Status](https://img.shields.io/travis/HANAI tohru/SparseRanges.svg?style=flat)](https://travis-ci.org/HANAI tohru/SparseRanges)
[![Version](https://img.shields.io/cocoapods/v/SparseRanges.svg?style=flat)](https://cocoapods.org/pods/SparseRanges)
[![License](https://img.shields.io/cocoapods/l/SparseRanges.svg?style=flat)](https://cocoapods.org/pods/SparseRanges)
[![Platform](https://img.shields.io/cocoapods/p/SparseRanges.svg?style=flat)](https://cocoapods.org/pods/SparseRanges)

A collection of CountableRange objects that expresses a sparsed range.

```swift
var r = SparseCountableRange<Int>()
r.add(10..<20)  // [10..<20]          adds a range.
r.add(30..<40)  // [10..<20, 30..<40] adds one more range, now it contains two ranges.
r.add(35..<50)  // [10..<20, 30..<50] adds another but it will be merged with the second one.
r.add(15..<35)  // [10..<50]          adds another and it will merge all because it overlaps with them.
```

## Unit testing

To run the unit testing project, clone the repo, and run `pod install` from the Example
directory first. Then open it on xcode and invoke the test from the menu _[Product]-[Test]_.

## Installation

SparseRanges is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SparseRanges'
```

## Contributing

It is always welcomed to send me a feature request or a pull request to make the
library more valuable.  
The current implementation has very limited functionality just because it hasn't
had many use cases.


## Author

HANAI tohru, [tohru@reedom.com](mailto:tohru@reedom.com)

## License

SparseRanges is available under the MIT license. See the LICENSE file for more info.
