// swift-tools-version:5.0

import PackageDescription

let package = Package(name: "PushNotifications",
                      platforms: [.macOS(.v10_10),
                                  .iOS(.v10)],
                      products: [
                        .library(name: "PushNotifications",
                                 targets: ["PushNotifications"])
                      ],
                      dependencies: [
                        .package(url: "https://github.com/Quick/Nimble",
                                 .upToNextMajor(from: "9.2.0")),
                        .package(url: "https://github.com/AliSoftware/OHHTTPStubs",
                                 .upToNextMajor(from: "9.1.0")),
                        // Source code linting
                        .package(url: "https://github.com/realm/SwiftLint",
                                 .upToNextMajor(from: "0.43.1"))
                      ],
                      targets: [
                        .target(name: "PushNotifications",
                                path: "Sources"),
                        .testTarget(name: "PushNotificationsTests",
                                    dependencies: ["PushNotifications",
                                                   "Nimble",
                                                   "OHHTTPStubs",
                                                   "OHHTTPStubsSwift"],
                                    path: "Tests")
                      ],
                      swiftLanguageVersions: [.v5])
