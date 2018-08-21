import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: [String]?

    static func persist(_ deviceId: String) {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.set(deviceId, forKey: Constants.UserDefaults.deviceId)
    }

    static func getDeviceId() -> String? {
        return UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.string(forKey: Constants.UserDefaults.deviceId)
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
