import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: Set<String>?

    private static let userDefaults = UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)

    static func persist(_ deviceId: String) {
        userDefaults?.set(deviceId, forKey: PersistenceConstants.UserDefaults.deviceId)
    }

    static func delete() {
        userDefaults?.removeObject(forKey: PersistenceConstants.UserDefaults.deviceId)
    }

    static func persistAPNsToken(token: String) {
        userDefaults?.set(token, forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }

    static func deleteAPNsToken() {
        userDefaults?.removeObject(forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }

    static func getDeviceId() -> String? {
        return userDefaults?.string(forKey: PersistenceConstants.UserDefaults.deviceId)
    }

    static func getAPNsToken() -> String? {
        return userDefaults?.string(forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
