import Foundation

public class DeviceStateStore {
    static let queue = DispatchQueue(label: "deviceStateStoreQueue")
    static let interestsService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)
    static let usersService: UserPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)
    static let pushNotificationsInstance: PushNotificationsInstancePersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)

    public static func synchronize<T>(f: () -> T) -> T {
        var result: T? = nil
        DeviceStateStore.queue.sync {
            result = f()
        }
        return result!
    }
}
