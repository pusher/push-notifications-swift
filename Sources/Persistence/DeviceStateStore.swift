import Foundation

public class DeviceStateStore {
    static let queue = DispatchQueue(label: "deviceStateStoreQueue")
    static let interestsService: PersistenceService =
        PersistenceService(service: UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)!)
    static let usersService: PersistenceService =
        PersistenceService(service: UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)!)
    static let pushNotificationsInstance: PersistenceService =
        PersistenceService(service: UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)!)

    public static func synchronize<T>(f: () -> T) -> T {
        var result: T?
        DeviceStateStore.queue.sync {
            result = f()
        }
        return result!
    }
}
