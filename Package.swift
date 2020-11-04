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
                                 .upToNextMajor(from: "8.1.2")),
                        .package(url: "https://github.com/AliSoftware/OHHTTPStubs",
                                 .upToNextMajor(from: "9.0.0")),
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
                      swiftLanguageVersions: [.v4, .v4_2, .v5])
