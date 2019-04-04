import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: Set<String>?

    private static let userDefaults = UserDefaults(suiteName: Constants.UserDefaults.suiteName)

    static func persist(_ deviceId: String) {
        userDefaults?.set(deviceId, forKey: Constants.UserDefaults.deviceId)
    }

    static func delete() {
        userDefaults?.removeObject(forKey: Constants.UserDefaults.deviceId)
    }

    static func persistAPNsToken(token: String) {
        userDefaults?.set(token, forKey: Constants.UserDefaults.deviceAPNsToken)
    }

    static func deleteAPNsToken() {
        userDefaults?.removeObject(forKey: Constants.UserDefaults.deviceAPNsToken)
    }

    static func getDeviceId() -> String? {
        return userDefaults?.string(forKey: Constants.UserDefaults.deviceId)
    }

    static func getAPNsToken() -> String? {
        return userDefaults?.string(forKey: Constants.UserDefaults.deviceAPNsToken)
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
