#if os(iOS)
import UIKit
import Foundation
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif

@objc public final class PushNotifications: NSObject {
    private var deviceId: String?
    private var instanceId: String?
    private var baseURL: String?
    private let session = URLSession.shared
    
    //! Returns a shared singleton PushNotifications object.
    @objc public static let shared = PushNotifications()

    /**
     Register with PushNotifications service.

     - Parameter instanceId: PushNotifications instance id.
     - Parameter application: Your singleton app object.

     - Precondition: `instanceId` should not be nil.
     - Precondition: `application` should not be nil.
     */
    #if os(iOS)
    @objc public func register(instanceId: String, application: UIApplication = UIApplication.shared) {
        self.instanceId = instanceId
        self.baseURL = "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances"
        self.registerForPushNotifications(application: application)
    }
    #elseif os(OSX)
    @objc public func register(instanceId: String, application: NSApplication = NSApplication.shared) {
        self.instanceId = instanceId
        self.baseURL = "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances"
        self.registerForPushNotifications(application: application)
    }
    #endif

    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     - Parameter completion: The block to execute when the register device token operation is complete.

     - Precondition: `deviceToken` should not be nil.
     */
    @objc public func registerDeviceToken(_ deviceToken: Data, completion: @escaping () -> Void = {}) {
        guard
            let instanceId = self.instanceId,
            let baseURL = self.baseURL,
            let url = URL(string: "\(baseURL)/\(instanceId)/devices/apns")
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

     - Throws: An error of type `InvalidInterestError`
     */
    @objc public func subscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let baseURL = self.baseURL,
            let url = URL(string: "\(baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if persistenceService.persist(interest: interest) {
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

     - Throws: An error of type `MultipleInvalidInterestsError`
     */
    @objc public func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void = {}) throws {
        if let invalidInterests = self.validateInterestNames(interests) {
            throw MultipleInvalidInterestsError.invalidNames(invalidInterests)
        }

        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let baseURL = self.baseURL,
            let url = URL(string: "\(baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        persistenceService.persist(interests: interests)
        networkService.setSubscriptions(interests: interests) {
            completion()
        }
    }

    /**
     Unsubscribe from an interest.

     - Parameter interest: Interest that you want to unsubscribe to.
     - Parameter completion: The block to execute when subscription to the interest is successfully cancelled.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    @objc public func unsubscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let baseURL = self.baseURL,
            let url = URL(string: "\(baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if persistenceService.remove(interest: interest) {
            networkService.unsubscribe {
                completion()
            }
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    @objc public func unsubscribeAll(completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let baseURL = self.baseURL,
            let url = URL(string: "\(baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: PushNotificationsRegisterable & PushNotificationsSubscribable = NetworkService(url: url, session: session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        persistenceService.removeAll()
        networkService.unsubscribeAll {
            completion()
        }
    }

    /**
     Get a list of all interests.

     - returns: Array of interests
     */
    @objc public func getInterests() -> Array<String>? {
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        return persistenceService.getSubscriptions()
    }

<<<<<<< HEAD
    private func validateInterestName(_ interest: String) -> Bool {
        let interestNameRegex = "^[a-zA-Z0-9_=@,.;]{1,164}$"
        let interestNamePredicate = NSPredicate(format:"SELF MATCHES %@", interestNameRegex)
        return interestNamePredicate.evaluate(with: interest)
    }

    private func validateInterestNames(_ interests: Array<String>) -> Array<String>? {
        return interests.filter { !self.validateInterestName($0) }
    }

=======
    #if os(iOS)
>>>>>>> Add support for macOS
    private func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    #elseif os(OSX)
    private func registerForPushNotifications(application: NSApplication) {
        application.registerForRemoteNotifications(matching: [.alert, .sound, .badge])
    }
    #endif
}
