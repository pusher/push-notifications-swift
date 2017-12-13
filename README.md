# PushNotifications iOS SDK

[![Documentation](https://push-notifications-swift.herokuapp.com/badge.svg)](https://push-notifications-swift.herokuapp.com/Classes/PushNotifications.html)
![](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/PushNotifications.svg)](https://cocoapods.org/pods/PushNotifications)
[![Carthage](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)

## Building and Running

### Minimum Requirements
* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835) - The easiest way to get Xcode is from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12), but you can also download it from [developer.apple.com](https://developer.apple.com/) if you have an AppleID registered with an Apple Developer account.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods version 1.3.1 or newer is recommended to build PushNotifications.

To integrate PushNotifications into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target '<Your Target Name>' do
    pod 'PushNotifications'
end
```

Then, run the following command:

```bash
$ pod install --repo-update
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

> Carthage version 0.26.2 or newer is recommended to build PushNotifications.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PushNotifications into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/push-notifications-swift"
```

Run `carthage update` to build the framework and drag the built `PushNotifications.framework`into your Xcode project.

## Communication

- Found a bug? Please open an [issue](https://github.com/pusher/push-notifications-swift/issues).
- Have a feature request. Please open an [issue](https://github.com/pusher/push-notifications-swift/issues).
- If you want to contribute, please submit a [pull request](https://github.com/pusher/push-notifications-swift/pulls) (preferrably with some tests).


## Credits

PushNotifications is owned and maintained by [Pusher](https://pusher.com).


## License

PushNotifications is released under the MIT license. See [LICENSE](https://github.com/pusher/push-notifications-swift/blob/master/LICENSE) for details.
