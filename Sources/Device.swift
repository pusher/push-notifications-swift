import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: [String]?

    static func persist(deviceId: String) {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.set(deviceId, forKey: Constants.UserDefaults.deviceId)
    }

    static func getDeviceId() -> String? {
        return UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.string(forKey: Constants.UserDefaults.deviceId)
    }

    static func persist(deviceToken: String) {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.set(deviceToken, forKey: Constants.UserDefaults.deviceToken)
    }

    static func tokenHasChanged(deviceToken: String) -> Bool {
        guard let persistedDeviceToken = UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.string(forKey: Constants.UserDefaults.deviceToken) else {
            return true
        }

        return deviceToken != persistedDeviceToken
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
