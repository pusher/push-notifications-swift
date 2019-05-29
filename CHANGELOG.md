# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/push-notifications-swift/compare/2.0.2...HEAD)

## [2.0.2](https://github.com/pusher/push-notifications-swift/compare/2.0.1...2.0.2) - 2019-05-29

## Added

- Support for macOS versions:

  - `10.10`
  - `10.11`

## [2.0.1](https://github.com/pusher/push-notifications-swift/compare/2.0.0...2.0.1) - 2019-05-28

## Changed

- Improve cases when a warning message is displayed.

## [2.0.0](https://github.com/pusher/push-notifications-swift/compare/1.3.0...2.0.0) - 2019-04-12

## Added

- Performance and reliability improvements.

## Changed

- Simplified completion handlers:

  - `registerDeviceToken(_ deviceToken:, completion:)` to `func registerDeviceToken(_ deviceToken:)`
  - `addDeviceInterest(interest:, completion:)` to `func addDeviceInterest(interest:)`
  - `setDeviceInterests(interests:, completion:)` to `func setDeviceInterests(interests:)`
  - `removeDeviceInterest(interest:, completion:)` to `func removeDeviceInterest(interest:)`
  - `stop(completion: @escaping (Error?) -> Void)` to `func stop(completion: @escaping () -> Void)`
  - `clearDeviceInterests(completion:)` to `func clearDeviceInterests()`
  - `clearAllState(completion: @escaping (Error?) -> Void)` to `clearAllState(completion: @escaping () -> Void)`

## Removed

- Removed deprecated methods:

  - `subscribe(interest:, completion:)`
  - `setSubscriptions(interests:, completion:)`
  - `unsubscribe(interest: String, completion:)`
  - `unsubscribeAll(completion:)`
  - `getInterests()`
  - `interestsSetDidChange(interests:)`

- We no longer support macOS versions:

  - `10.10`
  - `10.11`

## [1.3.0](https://github.com/pusher/push-notifications-swift/compare/1.3.0-beta.1...1.3.0) - 2019-03-25

## Added

- Add optional `userId` to the event type payload.

## [1.3.0-beta.1](https://github.com/pusher/push-notifications-swift/compare/1.2.1...1.3.0-beta.1) - 2019-02-21

## Added

- Return '.ShouldProcess' if push notification payload contains customer provided 'data' and application is in foreground.

## [1.2.1](https://github.com/pusher/push-notifications-swift/compare/1.2.0...1.2.1) - 2019-02-20

## Added

- Call completion handler if device id is already present.

## [1.2.0](https://github.com/pusher/push-notifications-swift/compare/1.1.0...1.2.0) - 2019-02-06

## Added

- A secure method to directly target a notification to an [authenticated user](https://docs.pusher.com/beams/concepts/authenticated-users) in your application.

## [1.1.0](https://github.com/pusher/push-notifications-swift/compare/1.0.1...1.1.0) - 2018-09-20

## Added

- Compatibility with Xcode 10.0

## [1.0.1](https://github.com/pusher/push-notifications-swift/compare/1.0.0...1.0.1) - 2018-08-22

## Changed

- Minor internal improvements.

## [1.0.0](https://github.com/pusher/push-notifications-swift/compare/0.10.11...1.0.0) - 2018-07-31

- General availability (GA) release.

## [0.10.12](https://github.com/pusher/push-notifications-swift/compare/0.10.11...0.10.12) - 2018-07-17

### Added

- Optimized sync strategy (sync only if interests change).

## [0.10.11](https://github.com/pusher/push-notifications-swift/compare/0.10.10...0.10.11) - 2018-07-04

### Added

- Retry strategy with exponential backoff - if the HTTP request fails, SDK will retry that request.
- Improved thread safeness.

## [0.10.10](https://github.com/pusher/push-notifications-swift/compare/0.10.9...0.10.10) - 2018-06-25

### Added

- `interestsSetDidChange(interests:)` will be called when interests set changes.

## [0.10.9](https://github.com/pusher/push-notifications-swift/compare/0.10.8...0.10.9) - 2018-06-18

### Fixed

- Synchronization logic of the `subscribe` method.

## [0.10.8](https://github.com/pusher/push-notifications-swift/compare/0.10.7...0.10.8) - 2018-06-13

### Added

- Migration mechanism that syncs interests from Push Notifications BETA service to Pusher Beams.

## [0.10.7](https://github.com/pusher/push-notifications-swift/compare/0.10.6...0.10.7) - 2018-04-24

### Added

- Applied recommended settings by Xcode 9.3 to the example projects.
- Ability to ignore Pusher related remote notifications. PR: [#60](https://github.com/pusher/push-notifications-swift/pull/60)

## [0.10.6](https://github.com/pusher/push-notifications-swift/compare/0.10.5...0.10.6) - 2018-04-04

### Added

- `X-Pusher-Library` HTTP header field.

### Changed

- Open/Delivery Event Schemas

## [0.10.5](https://github.com/pusher/push-notifications-swift/compare/0.10.4...0.10.5) - 2018-03-20

### Added

- All asynchronous tasks are added into the serial queue in order to prevent race conditions.
- Execution of the tasks in the serial queue is suspended until we receive device id.

### Changed

- Minor improvements to the unit tests.

## [0.10.4](https://github.com/pusher/push-notifications-swift/compare/0.10.3...0.10.4) - 2018-03-13

### Changed

- Allow '-' (dash) character in the interest name as service now supports it.

## [0.10.3](https://github.com/pusher/push-notifications-swift/compare/0.10.2...0.10.3) - 2018-03-07

### Added

- Sync interests with Pusher Push Notifications service when app starts.

### Fixed

- Bug when `setSubscriptions` method would throw an exception.
