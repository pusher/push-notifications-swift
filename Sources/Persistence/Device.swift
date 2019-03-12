import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: Set<String>?

    static func persist(_ deviceId: String) {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.set(deviceId, forKey: Constants.UserDefaults.deviceId)
    }

    static func persistAPNsToken(token: String) {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.set(token, forKey: Constants.UserDefaults.deviceAPNsToken)
    }

    static func getDeviceId() -> String? {
        return UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.string(forKey: Constants.UserDefaults.deviceId)
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
