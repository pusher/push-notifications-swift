#if os(iOS)
import UIKit
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif
import Foundation

@objc public final class PushNotifications: NSObject {
    private let session = URLSession(configuration: .default)
    private let preIISOperationQueue = DispatchQueue(label: Constants.DispatchQueue.preIISOperationQueue)
    private let persistenceStorageOperationQueue = DispatchQueue(label: Constants.DispatchQueue.persistenceStorageOperationQueue)
    private let networkService: PushNotificationsNetworkable

    // The object that acts as the delegate of push notifications.
    public weak var delegate: InterestsChangedDelegate?

    //! Returns a shared singleton PushNotifications object.
    /// - Tag: shared
    @objc public static let shared = PushNotifications()

    public override init() {
        self.networkService = NetworkService(session: self.session)

        if !Device.idAlreadyPresent() {
            preIISOperationQueue.suspend()
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
        if !wasCalledFromCorrectLocation {
            print("[Push Notifications] - Warning: You should call `pushNotifications.start` from the `AppDelegate.didFinishLaunchingWith`")
        }

        do {
            try Instance.persist(instanceId)
        } catch PusherAlreadyRegisteredError.instanceId(let errorMessage) {
            print("[Push Notifications] - \(errorMessage)")
        } catch {
            print("[Push Notifications] - Unexpected error: \(error).")
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
            print("[Push Notifications] - Something went wrong. Please check your instance id: \(String(describing: Instance.getInstanceId()))")
            return
        }

        if Device.idAlreadyPresent() {
            // If we have the device id that means that the token has already been registered.
            // Therefore we don't need to call `networkService.register` again.
            print("[Push Notifications] - Warning: Avoid multiple calls of `registerDeviceToken`")
            return
        }

        networkService.register(url: url, deviceToken: deviceToken, instanceId: instanceId) { [weak self] (device) in
            guard
                let device = device,
                let strongSelf = self
            else {
                return
            }

            strongSelf.persistenceStorageOperationQueue.async {
                if Device.idAlreadyPresent() {
                    print("[Push Notifications] - Warning: Avoid multiple calls of `registerDeviceToken`")
                } else {
                    Device.persist(device.id)

                    let initialInterestSet = device.initialInterestSet ?? []
                    let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: "PushNotifications")!)
                    if initialInterestSet.count > 0 {
                        persistenceService.persist(interests: initialInterestSet)
                    }

                    strongSelf.preIISOperationQueue.async {
                        let interests = persistenceService.getSubscriptions() ?? []
                        if !initialInterestSet.containsSameElements(as: interests) {
                            strongSelf.syncInterests()
                        }

                        completion()
                    }

                    strongSelf.preIISOperationQueue.resume()
                }
            }
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

        self.persistenceStorageOperationQueue.async {
            let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)

            let interestAdded = persistenceService.persist(interest: interest)

            if Device.idAlreadyPresent() {
                if interestAdded {
                    guard
                        let deviceId = Device.getDeviceId(),
                        let instanceId = Instance.getInstanceId(),
                        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
                    else {
                        return
                    }

                    let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
                    networkService.subscribe(url: url, completion: { _ in
                        completion()
                    })
                }
            } else {
                self.preIISOperationQueue.async {
                    persistenceService.persist(interest: interest)
                    completion()
                }
            }

            if interestAdded {
                self.interestsSetDidChange()
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
    @objc public func setSubscriptions(interests: [String], completion: @escaping () -> Void = {}) throws {
        if let invalidInterests = self.validateInterestNames(interests), invalidInterests.count > 0 {
            throw MultipleInvalidInterestsError.invalidNames(invalidInterests)
        }

        self.persistenceStorageOperationQueue.async {
            let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)

            let interestsChanged = persistenceService.persist(interests: interests)

            if Device.idAlreadyPresent() {
                if interestsChanged {
                    guard
                        let deviceId = Device.getDeviceId(),
                        let instanceId = Instance.getInstanceId(),
                        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")
                    else {
                        return
                    }

                    let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
                    networkService.setSubscriptions(url: url, interests: interests, completion: { _ in
                        completion()
                    })
                }
            } else {
                self.preIISOperationQueue.async {
                    persistenceService.persist(interests: interests)
                    completion()
                }
            }

            if interestsChanged {
                self.interestsSetDidChange()
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

        self.persistenceStorageOperationQueue.async {
            let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)

            let interestRemoved = persistenceService.remove(interest: interest)

            if Device.idAlreadyPresent() {
                if interestRemoved {
                    guard
                        let deviceId = Device.getDeviceId(),
                        let instanceId = Instance.getInstanceId(),
                        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
                        else { return }

                    let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
                    networkService.unsubscribe(url: url, completion: { _ in
                        completion()
                    })
                }
            } else {
                self.preIISOperationQueue.async {
                    persistenceService.remove(interest: interest)
                    completion()
                }
            }

            if interestRemoved {
                self.interestsSetDidChange()
            }
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    /// - Tag: unsubscribeAll
    @objc public func unsubscribeAll(completion: @escaping () -> Void = {}) throws {
        try self.setSubscriptions(interests: [], completion: completion)
    }

    /**
     Get a list of all interests.

     - returns: Array of interests
     */
    /// - Tag: getInterests
    @objc public func getInterests() -> [String]? {
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)

        return persistenceService.getSubscriptions()
    }

    @objc public func interestsSetDidChange() {
        guard
            let delegate = delegate,
            let interests = self.getInterests()
        else {
            return
        }

        return delegate.interestsSetDidChange(interests: interests)
    }

    /**
     Handle Remote Notification.

     - Parameter userInfo: Remote Notification payload.
     */
    /// - Tag: handleNotification
    @discardableResult
    @objc public func handleNotification(userInfo: [AnyHashable: Any]) -> RemoteNotificationType {
        guard FeatureFlags.DeliveryTrackingEnabled else {
            return .ShouldProcess
        }

        #if os(iOS)
            let applicationState = UIApplication.shared.applicationState
            guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: applicationState) else {
                return .ShouldProcess
            }
        #elseif os(OSX)
            guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo) else {
                return .ShouldProcess
            }
        #endif

        guard
            let instanceId = Instance.getInstanceId(),
            let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v2/instances/\(instanceId)/events")
        else {
            return EventTypeHandler.getRemoteNotificationType(userInfo)
        }

        let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
        networkService.track(url: url, eventType: eventType, completion: { _ in })

        return EventTypeHandler.getRemoteNotificationType(userInfo)
    }

    private func validateInterestName(_ interest: String) -> Bool {
        let interestNameRegex = "^[a-zA-Z0-9_\\-=@,.;]{1,164}$"
        let interestNamePredicate = NSPredicate(format: "SELF MATCHES %@", interestNameRegex)
        return interestNamePredicate.evaluate(with: interest)
    }

    private func validateInterestNames(_ interests: [String]) -> [String]? {
        return interests.filter { !self.validateInterestName($0) }
    }

    private func syncMetadata() {
        guard
            let deviceId = Device.getDeviceId(),
            let instanceId = Instance.getInstanceId(),
            let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")
        else {
            return
        }

        let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
        networkService.syncMetadata(url: url, completion: { _ in })
    }

    private func syncInterests() {
        // Sync saved interests when app starts, if necessary.
        guard
            let interests = self.getInterests(),
            let deviceId = Device.getDeviceId(),
            let instanceId = Instance.getInstanceId(),
            let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")
        else {
            return
        }

        let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
        let persistenceService: InterestPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)
        let interestsHash = interests.calculateMD5Hash()
        if interestsHash != persistenceService.getServerConfirmedInterestsHash() {
            networkService.setSubscriptions(url: url, interests: interests, completion: { _ in
                persistenceService.persistServerConfirmedInterestsHash(interestsHash)
            })
        }
    }

    #if os(iOS)
    private func registerForPushNotifications(options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("[Push Notifications] - \(error.localizedDescription)")
            }
        }
    }
    #elseif os(OSX)
    private func registerForPushNotifications(options: NSApplication.RemoteNotificationType) {
        NSApplication.shared.registerForRemoteNotifications(matching: options)
    }
    #endif
}

/**
 InterestsChangedDelegate protocol.
 Method `interestsSetDidChange(interests:)` will be called when interests set changes.
 */
@objc public protocol InterestsChangedDelegate: class {
    /**
     Tells the delegate that the interests list has changed.

     - Parameter interests: The new list of interests.
     */
    /// - Tag: interestsSetDidChange
    func interestsSetDidChange(interests: [String])
}
