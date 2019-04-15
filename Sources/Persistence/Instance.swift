import Foundation

struct Instance {
    private static let key = Constants.UserDefaults.instanceId
    private static let userDefaults = UserDefaults(suiteName: Constants.UserDefaults.suiteName)!

    static func persist(_ instanceId: String) {
        self.userDefaults.set(instanceId, forKey: key)
    }

    static func getInstanceId() -> String? {
        return self.userDefaults.string(forKey: key)
    }
}
