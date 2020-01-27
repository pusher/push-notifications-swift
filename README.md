# Pusher Beams iOS & macOS SDK

![Build Status](https://app.bitrise.io/app/2798096bb06e322f/status.svg?token=GHiO2KcqAY_UDS8g8M-f5g)
[![codecov](https://codecov.io/gh/pusher/push-notifications-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/pusher/push-notifications-swift)
[![Documentation](https://pusher.github.io/push-notifications-swift/badge.svg)](https://pusher.github.io/push-notifications-swift/Classes/PushNotifications.html)
[![CocoaPods](https://img.shields.io/cocoapods/v/PushNotifications.svg)](https://cocoapods.org/pods/PushNotifications)
[![Carthage](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)

## Example Code

- [iOS with Swift](https://github.com/pusher/push-notifications-swift/blob/master/push-notifications-ios/push-notifications-ios/AppDelegate.swift)
- [iOS with Objective-C](https://github.com/pusher/push-notifications-swift/blob/master/push-notifications-objc/push-notifications-objc/AppDelegate.m)
- [macOS with Swift](https://github.com/pusher/push-notifications-swift/blob/master/push-notifications-mac/push-notifications-mac/AppDelegate.swift)
- [macOS with Objective-C](https://github.com/pusher/push-notifications-swift/blob/master/push-notifications-mac-objc/push-notifications-mac-objc/AppDelegate.m)

## Building and Running

### Minimum Requirements

- [Swift 4.0+](https://github.com/pusher/push-notifications-swift/commit/d6dfa2186195135d8d7d1e3d3efdd7f8661ea404)
- [Xcode](https://itunes.apple.com/us/app/xcode/id497799835) - The easiest way to get Xcode is from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12), but you can also download it from [developer.apple.com](https://developer.apple.com/) if you have an AppleID registered with an Apple Developer account.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods version 1.3.1 or newer is recommended to build Pusher Beams.

To integrate Pusher Beams into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target '<Your Target Name>' do
    pod 'PushNotifications', '~> 3.0.4'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

> Carthage version 0.26.2 or newer is recommended to build Pusher Beams.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Pusher Beams into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/push-notifications-swift"
```

Continue following the steps below depending on the platform that you're building the dependency for:

- If you're building for OS X, follow [this](https://github.com/Carthage/Carthage#if-youre-building-for-os-x) guide.
- If you're building for iOS, tvOS, or watchOS, follow [this](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) guide.

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.


####  Manual Xcode integration

To integrate Pusher Beams into your Xcode project using Swift Package Manager, in your Xcode choose `File` > `Swift Packages` > `Add Package Dependency...`  and provide the following URL:

```
https://github.com/pusher/push-notifications-swift
```

####  Swift Package Manager dependency

To add Pusher Beams as a dependency of your own package use the follwing code:

```swift
dependencies: [
    .package(url: "https://github.com/pusher/push-notifications-swift.git", from: "3.0.4")
]
```

## Migrating from 2.x.x to 3.x.x

We now require you to start beams before you can use the library, for example to register any interests. This means the following code would no longer work and log an error to the console:

```Swift
try! PushNotifications.shared.addDeviceInterest("donuts")
PushNotifications.shared.start("YOUR_INSTANCE_ID")
```

You now need to replace it with the following:

```Swift
PushNotifications.shared.start("YOUR_INSTANCE_ID")
try! PushNotifications.shared.addDeviceInterest("donuts")
```

We recommend start is always called in the `application didFinishLaunchingWithOptions` callback. Note that you can still control when you show the request for push notification prompt, start does not call this prompt.

## Running Tests

### Generating Test Coverage Reports

We're using [Slather](https://github.com/SlatherOrg/slather) for generating test coverage reports locally and [Codecov](https://codecov.io/) when pull requests are submitted.

### Using Slather

Create a report as static html pages by running:

```bash
slather coverage --html --scheme PushNotifications --workspace PushNotifications.xcworkspace/ PushNotifications/PushNotifications.xcodeproj/
```

Open the html reports:

```bash
open 'html/index.html'
```

## Pusher Beams Reference

- Autogenerated reference [docs](https://pusher.github.io/push-notifications-swift/Classes/PushNotifications.html).
- Pusher Beams iOS SDK [docs](https://docs.pusher.com/beams/reference/ios).

## Communication

- Found a bug? Please open an [issue](https://github.com/pusher/push-notifications-swift/issues).
- Have a feature request. Please open an [issue](https://github.com/pusher/push-notifications-swift/issues).
- If you want to contribute, please submit a [pull request](https://github.com/pusher/push-notifications-swift/pulls) (preferrably with some tests).

## Credits

Pusher Beams is owned and maintained by [Pusher](https://pusher.com).

## License

Pusher Beams is released under the MIT license. See [LICENSE](https://github.com/pusher/push-notifications-swift/blob/master/LICENSE) for details.
