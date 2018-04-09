# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/push-notifications-swift/compare/0.10.6...HEAD)

### Added

- Applied recommended settings by Xcode 9.3 to the example projects.

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
