#if os(iOS)
import UIKit
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif
import Foundation

@objc public final class PushNotifications: NSObject {
    private let session = URLSession.shared
    private let networkQueue = DispatchQueue(label: "com.pusher.pushnotifications.sdk.network.queue")
    private let localStorageQueue = DispatchQueue(label: "com.pusher.pushnotifications.local.storage.queue")

    // Used to suspend/resume the `networkQueue` and `localStorageQueue`.
    private let deviceIdAlreadyPresent: Bool

    //! Returns a shared singleton PushNotifications object.
    /// - Tag: shared
    @objc public static let shared = PushNotifications()

    public override init() {
        self.deviceIdAlreadyPresent = Device.idAlreadyPresent()

        if !self.deviceIdAlreadyPresent {
            networkQueue.suspend()
            localStorageQueue.suspend()
        }
    }

    /**
     Start PushNotifications service.

     - Parameter instanceId: PushNotifications instance id.

     - Precondition: `instanceId` should not be nil.
     */
    /// - Tag: start
    @objc public func start(instanceId: String) {
        // Detect from where the function is being called
        let wasCalledFromCorrectLocation = Thread.callStackSymbols.contains { stack in
            return stack.contains("didFinishLaunchingWith") || stack.contains("applicationDidFinishLaunching")
        }
        if (!wasCalledFromCorrectLocation) {
            print("Warning: You should call `pushNotifications.start` from the `AppDelegate.didFinishLaunchingWith`")
        }

        do {
            try Instance.persist(instanceId)
        } catch PusherAlreadyRegisteredError.instanceId(let errorMessage) {
            print(errorMessage)
        } catch {
            print("Unexpected error: \(error).")
        }

        self.syncMetadata()
        self.syncInterests()
    }

    /**
     Register to receive remote notifications via Apple Push Notification service.

     Convenience method is using `.alert`, `.sound`, and `.badge` as default authorization options.

     - SeeAlso:  `registerForRemoteNotifications(options:)`
     */
    /// - Tag: register
    @objc public func registerForRemoteNotifications() {
        self.registerForPushNotifications(options: [.alert, .sound, .badge])
    }
    #if os(iOS)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: The authorization options your app is requesting. You may combine the available constants to request authorization for multiple items. Request only the authorization options that you plan to use. For a list of possible values, see [UNAuthorizationOptions](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions).
     */
    /// - Tag: registerOptions
    @objc public func registerForRemoteNotifications(options: UNAuthorizationOptions) {
        self.registerForPushNotifications(options: options)
    }
    #elseif os(OSX)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: A bit mask specifying the types of notifications the app accepts. See [NSApplication.RemoteNotificationType](https://developer.apple.com/documentation/appkit/nsapplication.remotenotificationtype) for valid bit-mask values.
     */
    @objc public func registerForRemoteNotifications(options: NSApplication.RemoteNotificationType) {
        self.registerForPushNotifications(options: options)
    }
    #endif

    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     - Parameter completion: The block to execute when the register device token operation is complete.

     - Precondition: `deviceToken` should not be nil.
     */
    /// - Tag: registerDeviceToken
    @objc public func registerDeviceToken(_ deviceToken: Data, completion: @escaping () -> Void = {}) {
        guard
            let instanceId = Instance.getInstanceId(),
            let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")
        else {
            print("Something went wrong. Please check your instance id: \(String(describing: Instance.getInstanceId()))")
            return
        }

        let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: session)
        networkService.register(deviceToken: deviceToken, instanceId: instanceId) { [weak self] (device, _) in
            guard let device = device else { return }
            Device.persist(device.id)

            guard let strongSelf = self else { return }
            if !strongSelf.deviceIdAlreadyPresent {
                if let initialInterestSet = device.initialInterestSet, initialInterestSet.count > 0 {
                    let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)
                    persistenceService.persist(interests: initialInterestSet)
                }

                strongSelf.localStorageQueue.resume()
                strongSelf.networkQueue.resume()
            }

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
    /// - Tag: subscribe
    @objc public func subscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if Device.idAlreadyPresent() {
            if persistenceService.persist(interest: interest) {
                networkQueue.async {
                    guard
                        let deviceId = Device.getDeviceId(),
                        let instanceId = Instance.getInstanceId(),
                        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
                        else { return }

                    let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
                    networkService.subscribe(completion: { (_, _) in
                        completion()
                    })
                }
        } else {
                persistenceService.persist(interest: interest)
                localStorageQueue.async {
                    persistenceService.persist(interest: interest)
                    completion()
                }
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
    /// - Tag: setSubscriptions
    @objc public func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void = {}) throws {
        if let invalidInterests = self.validateInterestNames(interests), invalidInterests.count > 0 {
            throw MultipleInvalidInterestsError.invalidNames(invalidInterests)
        }

        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if Device.idAlreadyPresent() {
            persistenceService.persist(interests: interests)
            networkQueue.async {
                guard
                    let deviceId = Device.getDeviceId(),
                    let instanceId = Instance.getInstanceId(),
                    let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")
                    else { return }

                let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
                networkService.setSubscriptions(interests: interests, completion: { (_, _) in
                    completion()
                })
            }
        }
        else {
            persistenceService.persist(interests: interests)
            localStorageQueue.async {
                persistenceService.persist(interests: interests)
                completion()
            }
        }
    }

    /**
     Unsubscribe from an interest.

     - Parameter interest: Interest that you want to unsubscribe to.
     - Parameter completion: The block to execute when subscription to the interest is successfully cancelled.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: unsubscribe
    @objc public func unsubscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)
        if Device.idAlreadyPresent() {
            if persistenceService.remove(interest: interest) {
                networkQueue.async {
                    guard
                        let deviceId = Device.getDeviceId(),
                        let instanceId = Instance.getInstanceId(),
                        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
                    else { return }

                    let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
                    networkService.unsubscribe(completion: { (_, _) in
                        completion()
                    })
                }
            }
        } else {
            persistenceService.remove(interest: interest)
            localStorageQueue.async {
                persistenceService.remove(interest: interest)
                completion()
            }
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    /// - Tag: unsubscribeAll
    @objc public func unsubscribeAll(completion: @escaping () -> Void = {}) {
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        if Device.idAlreadyPresent() {
            persistenceService.removeAll()

            networkQueue.async {
                guard
                    let deviceId = Device.getDeviceId(),
                    let instanceId = Instance.getInstanceId(),
                    let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")
                    else { return }

                let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
                networkService.unsubscribeAll(completion: { (_, _) in
                    completion()
                })
            }
        }
        else {
            persistenceService.removeAll()
            localStorageQueue.async {
                persistenceService.removeAll()
                completion()
            }
        }
    }

    /**
     Get a list of all interests.

     - returns: Array of interests
     */
    /// - Tag: getInterests
    @objc public func getInterests() -> Array<String>? {
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)

        return persistenceService.getSubscriptions()
    }

    /**
     Handle Remote Notification.

     - Parameter userInfo: Remote Notification payload.
     */
    /// - Tag: handleNotification
    @discardableResult
    @objc public func handleNotification(userInfo: [AnyHashable: Any]) -> RemoteNotificationType {
        guard FeatureFlags.DeliveryTrackingEnabled else { return .ShouldProcess }

        #if os(iOS)
            let applicationState = UIApplication.shared.applicationState
        #endif

        networkQueue.async {
            #if os(iOS)
                guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: applicationState) else { return }
            #elseif os(OSX)
                guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo) else { return }
            #endif

            guard
                let instanceId = Instance.getInstanceId(),
                let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v2/instances/\(instanceId)/events")
            else { return }

            let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
            networkService.track(eventType: eventType, completion: { (_, _) in })
        }

        return EventTypeHandler.getRemoteNotificationType(userInfo)
    }

    private func validateInterestName(_ interest: String) -> Bool {
        let interestNameRegex = "^[a-zA-Z0-9_\\-=@,.;]{1,164}$"
        let interestNamePredicate = NSPredicate(format:"SELF MATCHES %@", interestNameRegex)
        return interestNamePredicate.evaluate(with: interest)
    }

    private func validateInterestNames(_ interests: Array<String>) -> Array<String>? {
        return interests.filter { !self.validateInterestName($0) }
    }

    private func syncMetadata() {
        networkQueue.async {
            guard
                let deviceId = Device.getDeviceId(),
                let instanceId = Instance.getInstanceId(),
                let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")
                else { return }

            let networkService: PushNotificationsNetworkable = NetworkService(url: url, session: self.session)
            networkService.syncMetadata(completion: { (_, _) in })

        }
    }

    private func syncInterests() {
        // Sync saved interests when app starts.
        guard let interests = self.getInterests() else { return }
        try? self.setSubscriptions(interests: interests)
    }

    #if os(iOS)
    private func registerForPushNotifications(options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    #elseif os(OSX)
    private func registerForPushNotifications(options: NSApplication.RemoteNotificationType) {
        NSApplication.shared.registerForRemoteNotifications(matching: options)
    }
    #endif
}
