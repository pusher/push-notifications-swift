import Foundation

public struct Metadata: Equatable, Codable {
    let sdkVersion: String?
    let iosVersion: String?
    let macosVersion: String?

    private static let userDefaults = UserDefaults(suiteName: Constants.UserDefaults.suiteName)

    static func getCurrentMetadata() -> Metadata {
        let sdkVersion = SDK.version
        let systemVersion = SystemVersion.version
        
        #if os(iOS)
        return Metadata(sdkVersion: sdkVersion, iosVersion: systemVersion, macosVersion: nil)
        #elseif os(OSX)
        return Metadata(sdkVersion: sdkVersion, iosVersion: nil, macosVersion: systemVersion)
        #endif
    }

    static func save(metadata: Metadata) {
        userDefaults?.set(metadata.sdkVersion, forKey: Constants.UserDefaults.metadataSDKVersion)
        userDefaults?.set(metadata.iosVersion, forKey: Constants.UserDefaults.metadataiOSVersion)
        userDefaults?.set(metadata.macosVersion, forKey: Constants.UserDefaults.metadataMacOSVersion)
    }

    static func load() -> Metadata {
        return Metadata(
            sdkVersion: userDefaults?.string(forKey: Constants.UserDefaults.metadataSDKVersion),
            iosVersion: userDefaults?.string(forKey: Constants.UserDefaults.metadataiOSVersion),
            macosVersion: userDefaults?.string(forKey: Constants.UserDefaults.metadataMacOSVersion)
        )
    }

    static func delete() {
        userDefaults?.removeObject(forKey: Constants.UserDefaults.metadataSDKVersion)
        userDefaults?.removeObject(forKey: Constants.UserDefaults.metadataiOSVersion)
        userDefaults?.removeObject(forKey: Constants.UserDefaults.metadataMacOSVersion)
    }
}
