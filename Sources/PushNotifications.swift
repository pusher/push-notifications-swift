import UIKit
import Foundation
import UserNotifications

public final class PushNotifications {
    private var deviceId: String?
    private var instanceId: String?
    private let session = URLSession.shared
    private let baseURL = "https://errol-staging.herokuapp.com/device_api/v1/instances"


    //! Returns a shared singleton PushNotifications object.
    public static let shared = PushNotifications()

    private init() {}

    /**
     Register with PushNotifications service.

     - Parameter instanceId: PushNotifications instance id.
     - Parameter application: Your singleton app object.

     - Precondition: `instanceId` should not be nil.
     - Precondition: `application` should not be nil.
     */
    public func register(instanceId: String, application: UIApplication = UIApplication.shared) {
        self.instanceId = instanceId
        self.registerForPushNotifications(application: application)
    }

    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     - Parameter completion: The block to execute when the register device token operation is complete.

     - Precondition: `deviceToken` should not be nil.
     */
    public func registerDeviceToken(_ deviceToken: Data, completion: @escaping () -> Void = {}) {
        guard
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken) { [weak self] (deviceId) in
            guard let strongSelf = self else { return }
            strongSelf.deviceId = deviceId
            completion()
        }
    }

    /**
     Subscribe to an interest.

     - Parameter interest: Interest that you want to subscribe to.
     - Parameter completion: The block to execute when subscription to the interest is complete.

     - Precondition: `interest` should not be nil.
     */
    public func subscribe(interest: String, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if (persistenceService.persist(interest: interest)) {
            networkService.subscribe {
                completion()
            }
        }
    }

    /**
     Set subscriptions.

     - Parameter interests: Interests that you want to subscribe to.
     - Parameter completion: The block to execute when subscription to interests is complete.

     - Precondition: `interests` should not be nil.
     */
    public func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if (persistenceService.persist(interests: interests)) {
            networkService.setSubscriptions(interests: interests) {
                completion()
            }
        }
    }

    /**
     Unsubscribe from an interest.

     - Parameter interest: Interest that you want to unsubscribe to.
     - Parameter completion: The block to execute when subscription to the interest is successfully cancelled.

     - Precondition: `interest` should not be nil.
     */
    public func unsubscribe(interest: String, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if (persistenceService.remove(interest: interest)) {
            networkService.unsubscribe {
                completion()
            }
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    public func unsubscribeAll(completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        networkService.unsubscribeAll {
            persistenceService.removeAll()
            completion()
        }
    }

    /**
     Get a list of all interests.

     - returns: Array of interests
     */
    public func getInterests() -> Array<String>? {
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        return persistenceService.getSubscriptions()
    }

    private func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}
