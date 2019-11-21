import Foundation

public struct Metadata: Equatable, Codable {
    let sdkVersion: String?
    let iosVersion: String?
    let macosVersion: String?

    private static let userDefaults = UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)

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
        userDefaults?.set(metadata.sdkVersion, forKey: PersistenceConstants.UserDefaults.metadataSDKVersion)
        userDefaults?.set(metadata.iosVersion, forKey: PersistenceConstants.UserDefaults.metadataiOSVersion)
        userDefaults?.set(metadata.macosVersion, forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
    }

    static func load() -> Metadata {
        return Metadata(
            sdkVersion: userDefaults?.string(forKey: PersistenceConstants.UserDefaults.metadataSDKVersion),
            iosVersion: userDefaults?.string(forKey: PersistenceConstants.UserDefaults.metadataiOSVersion),
            macosVersion: userDefaults?.string(forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
        )
    }

    static func delete() {
        userDefaults?.removeObject(forKey: PersistenceConstants.UserDefaults.metadataSDKVersion)
        userDefaults?.removeObject(forKey: PersistenceConstants.UserDefaults.metadataiOSVersion)
        userDefaults?.removeObject(forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
    }
}
