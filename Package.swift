// swift-tools-version:5.0

import PackageDescription

let package = Package(name: "PushNotifications",
                      platforms: [.macOS(.v10_10),
                                  .iOS(.v10)],
                      products: [.library(name: "PushNotifications",
                                          targets: ["PushNotifications"])],
                      targets: [.target(name: "PushNotifications",
                                        path: "Sources")],
                      swiftLanguageVersions: [.v4, .v4_2, .v5])
