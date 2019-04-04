#if os(iOS)
import UIKit
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif
import Foundation

@objc public final class PushNotifications: NSObject {
    private var serverSyncHandler = ServerSyncProcessHandler()
    // The object that acts as the delegate of push notifications.
    public weak var delegate: InterestsChangedDelegate?

    //! Returns a shared singleton PushNotifications object.
    /// - Tag: shared
    @objc public static let shared = PushNotifications()

    private var startHasBeenCalledThisSession = false

    /**
     Start PushNotifications service.

     - Parameter instanceId: PushNotifications instance id.

     - Precondition: `instanceId` should not be nil.
     */
    /// - Tag: start
    @objc public func start(instanceId: String) {
        let localInstanceId = Instance.getInstanceId()
        if localInstanceId != nil && localInstanceId != instanceId {
            let errorMessage = """
            This device has already been registered with Pusher.
            Push Notifications application with instance id: \(localInstanceId!).
            If you would like to register this device to \(instanceId) please reinstall the application.
            """

            print("[PushNotifications]: \(errorMessage)")
            return
        }
        Instance.persist(instanceId)

        // Detect from where the function is being called
        let wasCalledFromCorrectLocation = Thread.callStackSymbols.contains { stack in
            return stack.contains("didFinishLaunchingWith") || stack.contains("applicationDidFinishLaunching") || stack.contains("clearAllState")
        }
        if !wasCalledFromCorrectLocation {
            print("[PushNotifications]: Warning: You should call `pushNotifications.start` from the `AppDelegate.didFinishLaunchingWith`")
        }

        startHasBeenCalledThisSession = true
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
     Set user id.

     - Parameter userId: User id.
     - Parameter tokenProvider: Token provider that will be used to generate the token for the user that you want to authenticate.
    */
    /// - Tag: setUserId
    @objc public func setUserId(_ userId: String, tokenProvider: TokenProvider, completion: @escaping (Error?) -> Void) {
//        self.preIISOperationQueue.async {
//            let persistenceService: UserPersistable = PersistenceService(service: UserDefaults(suiteName: Constants.UserDefaults.suiteName)!)
//            if let persistedUserId = persistenceService.getUserId() {
//                if persistedUserId == userId {
//                    return completion(nil)
//                } else {
//                    return completion(TokenProviderError.error("[PushNotifications] - Changing the `userId` is not allowed."))
//                }
//            }
//
//            guard let deviceId = Device.getDeviceId() else {
//                return completion(TokenProviderError.error("[PushNotifications] - Device id is nil."))
//            }
//            guard let instanceId = Instance.getInstanceId() else {
//                return completion(TokenProviderError.error("[PushNotifications] - Instance id is nil."))
//            }
//            guard let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user") else {
//                return completion(TokenProviderError.error("[PushNotifications] - Error while constructing URL from a string."))
//            }
//
//            do {
//                try tokenProvider.fetchToken(userId: userId, completionHandler: { (token, error) in
//                    guard error == nil else {
//                        return completion(error)
//                    }
//
////                    let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
////                    networkService.setUserId(url: url, token: token, completion: { _ in
////                        persistenceService.setUserId(userId: userId)
////                        completion(nil)
////                    })
//                })
//            } catch {
//                completion(error)
//            }
//        }
    }

    /**
     Disable Beams service.

     This will remove everything associated with the Beams from the device and Beams server.
     */
    /// - Tag: stop
    @objc public func stop(completion: @escaping (Error?) -> Void) {
        let hadAnyInterests: Bool = DeviceStateStore.synchronize {
            let hadAnyInterests = DeviceStateStore.interestsService.getSubscriptions()?.isEmpty ?? false
            DeviceStateStore.interestsService.removeAllSubscriptions()

            return hadAnyInterests
        }

        if hadAnyInterests {
            self.interestsSetOnDeviceDidChange()
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.StopJob)
    }

    /**
     Clears all the state on the SDK leaving it in the empty started state.

     This will remove the current user and all the interests associated with it from the device and Beams server.
     Device is now in a fresh state, ready for new subscriptions or user being set.
     */
    /// - Tag: clearAllState
    @objc public func clearAllState(completion: @escaping (Error?) -> Void) {
        let instanceId = Instance.getInstanceId()
        self.stop { _ in }

        if instanceId != nil {
            self.start(instanceId: instanceId!)
            if let apnsToken = Device.getAPNsToken() {
                // Since we already had the token, we're forcing new device creation.
                self.registerDeviceToken(apnsToken.hexStringToData()!)
            }
        }
    }

    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     - Parameter completion: The block to execute when the register device token operation is complete.

     - Precondition: `deviceToken` should not be nil.
     */
    /// - Tag: registerDeviceToken
    @objc public func registerDeviceToken(_ deviceToken: Data, completion: @escaping () -> Void = {}) {
        guard
            let instanceId = Instance.getInstanceId()
        else {
            print("[Push Notifications] - Something went wrong. Please check your instance id: \(String(describing: Instance.getInstanceId()))")
            return
        }

        // TODO: Handle Token Refresh support
        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken.hexadecimalRepresentation()))
    }

    /**
     Subscribe to an interest.

     - Parameter interest: Interest that you want to subscribe to.
     - Parameter completion: The block to execute when subscription to the interest is complete.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: subscribe
    @available(*, deprecated, renamed: "addDeviceInterest(interest:completion:)")
    @objc public func subscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        try self.addDeviceInterest(interest: interest, completion: completion)
    }

    /**
     Subscribes the device to an interest.

     - Parameter interest: Interest that you want to subscribe your device to.
     - Parameter completion: The block to execute when subscription to the interest is complete.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: addDeviceInterest
    @objc public func addDeviceInterest(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let interestsChanged = DeviceStateStore.synchronize {
            DeviceStateStore.interestsService.persist(interest: interest)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.SubscribeJob(interest: interest, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
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
    @available(*, deprecated, renamed: "setDeviceInterests(interest:completion:)")
    @objc public func setSubscriptions(interests: [String], completion: @escaping () -> Void = {}) throws {
        try self.setDeviceInterests(interests: interests, completion: completion)
    }

    /**
     Sets the subscriptions state for the device.
     Any interests not in the set will be unsubscribed from, so this will replace the interest set by the one provided.

     - Parameter interests: Interests that you want to subscribe your device to.
     - Parameter completion: The block to execute when subscription to interests is complete.

     - Precondition: `interests` should not be nil.

     - Throws: An error of type `MultipleInvalidInterestsError`
     */
    /// - Tag: setDeviceInterests
    @objc public func setDeviceInterests(interests: [String], completion: @escaping () -> Void = {}) throws {
        if let invalidInterests = self.validateInterestNames(interests), invalidInterests.count > 0 {
            throw MultipleInvalidInterestsError.invalidNames(invalidInterests)
        }

        let interestsChanged = DeviceStateStore.synchronize {
            DeviceStateStore.interestsService.persist(interests: interests)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.SetSubscriptions(interests: interests, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
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
    @available(*, deprecated, renamed: "removeDeviceInterest(interest:completion:)")
    @objc public func unsubscribe(interest: String, completion: @escaping () -> Void = {}) throws {
        try self.removeDeviceInterest(interest: interest, completion: completion)
    }

    /**
     Unsubscribe the device from an interest.

     - Parameter interest: Interest that you want to unsubscribe your device from.
     - Parameter completion: The block to execute when subscription to the interest is successfully cancelled.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: removeDeviceInterest
     @objc public func removeDeviceInterest(interest: String, completion: @escaping () -> Void = {}) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let interestsChanged = DeviceStateStore.synchronize {
            DeviceStateStore.interestsService.remove(interest: interest)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.UnsubscribeJob(interest: interest, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    /// - Tag: unsubscribeAll
    @available(*, deprecated, renamed: "clearDeviceInterests(completion:)")
    @objc public func unsubscribeAll(completion: @escaping () -> Void = {}) throws {
        try self.clearDeviceInterests(completion: completion)
    }

    /**
     Unsubscribes the device from all the interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    /// - Tag: clearDeviceInterests
    @objc public func clearDeviceInterests(completion: @escaping () -> Void = {}) throws {
        try self.setDeviceInterests(interests: [], completion: completion)
    }

    /**
     Get a list of all interests.

     - returns: Array of interests
     */
    /// - Tag: getInterests
    @available(*, deprecated, renamed: "getDeviceInterests()")
    @objc public func getInterests() -> [String]? {
        return self.getDeviceInterests()
    }

    /**
     Get the interest subscriptions that the device is currently subscribed to.

     - returns: Array of interests
     */
    /// - Tag: getDeviceInterests
    @objc public func getDeviceInterests() -> [String]? {
        return DeviceStateStore.synchronize {
            return DeviceStateStore.interestsService.getSubscriptions()
        }
    }

    @available(*, deprecated, renamed: "interestsSetOnDeviceDidChange()")
    @objc public func interestsSetDidChange() {
        self.interestsSetOnDeviceDidChange()
    }

    @objc public func interestsSetOnDeviceDidChange() {
        guard
            let delegate = delegate,
            let interests = self.getDeviceInterests()
        else {
            return
        }

        return delegate.interestsSetOnDeviceDidChange(interests: interests)
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

//        let networkService: PushNotificationsNetworkable = NetworkService(session: self.session)
//        networkService.track(url: url, eventType: eventType, completion: { _ in })

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
 Method `interestsSetOnDeviceDidChange(interests:)` will be called when interests set changes.
 */
@objc public protocol InterestsChangedDelegate: class {
    /**
     Tells the delegate that the interests list has changed.

     - Parameter interests: The new list of interests.
     */
    /// - Tag: interestsSetDidChange
    @available(*, deprecated, renamed: "interestsSetOnDeviceDidChange(interests:)")
    func interestsSetDidChange(interests: [String])

    /**
     Tells the delegate that the device's interests subscriptions list has changed.

     - Parameter interests: The new list of interests.
     */
    /// - Tag: interestsSetOnDeviceDidChange
    func interestsSetOnDeviceDidChange(interests: [String])
}
