#if os(iOS)
import UIKit
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif
import Foundation

@objc public final class PushNotifications: NSObject {
    
    internal let instanceId: String
    private let deviceStateStore: InstanceDeviceStateStore
    private let serverSyncEventHandler: ServerSyncEventHandler
    
    // The object that acts as the delegate of push notifications.
    public weak var delegate: InterestsChangedDelegate?
    
    @objc public init(instanceId: String) {
        self.instanceId = instanceId
        self.deviceStateStore = InstanceDeviceStateStore(instanceId)
        self.serverSyncEventHandler = ServerSyncEventHandler.obtain(instanceId: instanceId)
        
        super.init()
        serverSyncEventHandler.registerInterestsChangedDelegate({ [weak self] in return self?.delegate })

        DeviceStateStore().persistInstanceId(instanceId)
    }
    
    //! Returns a shared singleton PushNotifications object.
    /// - Tag: shared
    @objc public static let shared = PushNotificationsStatic.self
    
    private lazy var serverSyncHandler = ServerSyncProcessHandler.obtain(
        instanceId: self.instanceId,
        getTokenProvider: { return PushNotifications.shared.tokenProvider[self.instanceId] },
        handleServerSyncEvent: { [weak self] (event) in
            self?.serverSyncEventHandler.handleEvent(event: event)
        }
    )

    private var startHasBeenCalledThisSession = false

    /**
     Start PushNotifications service.
     */
    /// - Tag: start
    @objc public func start() {
        if UUID(uuidString: instanceId) == nil {
            print("[PushNotifications]: '\(instanceId)' is not a valid instance id.")
            return
        }

        // Detect from where the function is being called
        let wasCalledFromCorrectLocation = Thread.callStackSymbols.contains { stack in
            return stack.contains("didFinishLaunchingWith") || stack.contains("applicationDidFinishLaunching") || stack.contains("clearAllState") || stack.contains("enablePushNotifications")
        }
        if !wasCalledFromCorrectLocation {
            print("[PushNotifications]: Warning: You should call `pushNotifications.start` from the `AppDelegate.didFinishLaunchingWith`")
        }

        startHasBeenCalledThisSession = true
        deviceStateStore.persistStartJobHasBeenEnqueued(flag: true)
        self.serverSyncHandler.sendMessage(serverSyncJob: .ApplicationStartJob(metadata: Metadata.current))
    }

    /**
     Register to receive remote notifications via Apple Push Notification service.

     Convenience method is using `.alert`, `.sound`, and `.badge` as default authorization options.

     - SeeAlso:  `registerForRemoteNotifications(options:)`
     */
    /// - Tag: register
    @objc public func registerForRemoteNotifications() {
        PushNotificationsStatic.registerForRemoteNotifications()
    }
    #if os(iOS)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: The authorization options your app is requesting. You may combine the available constants to request authorization for multiple items. Request only the authorization options that you plan to use. For a list of possible values, see [UNAuthorizationOptions](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions).
     */
    /// - Tag: registerOptions
    @objc public func registerForRemoteNotifications(options: UNAuthorizationOptions) {
        PushNotificationsStatic.registerForRemoteNotifications(options: options)
    }
    #elseif os(OSX)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: A bit mask specifying the types of notifications the app accepts. See [NSApplication.RemoteNotificationType](https://developer.apple.com/documentation/appkit/nsapplication.remotenotificationtype) for valid bit-mask values.
     */
    @objc public func registerForRemoteNotifications(options: NSApplication.RemoteNotificationType) {
        PushNotificationsStatic.registerForRemoteNotifications(options: options)
    }
    #endif

    /**
     Set user id.

     - Parameter userId: User id.
     - Parameter tokenProvider: Token provider that will be used to generate the token for the user that you want to authenticate.
     - Parameter completion: The block to execute after attempt to set user id has been made.
    */
    /// - Tag: setUserId
    @objc public func setUserId(_ userId: String, tokenProvider: TokenProvider, completion: @escaping (Error?) -> Void) {
        if startHasBeenCalledThisSession == false {
            completion(PushNotificationsError.error("[PushNotifications] - `start` method must be called before setting `userId`"))
            return
        }

        PushNotifications.shared.tokenProvider[self.instanceId] = tokenProvider

        var localUserIdDifferent: Bool?
        InstanceDeviceStateStore.synchronize {
            if let userIdExists = self.deviceStateStore.getUserIdHasBeenCalledWith() {
                localUserIdDifferent = userIdExists != userId
            } else {
                self.deviceStateStore.persistUserIdHasBeenCalledWith(userId: userId)
            }
        }
        switch localUserIdDifferent {
        case .none:
            // There was no user id previously stored.
            break
        case .some(false):
            // Although there was a previous call with the same user id, it might still be in progress
            // therefore, for the callbacks to work, we will just enqueue the `.SetUserIdJob`
            break
        case .some(true):
            completion(TokenProviderError.error("[PushNotifications] - Changing the `userId` is not allowed."))
            return
        }

        let helpfulTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(printHelpfulMessage), userInfo: nil, repeats: false)

        let wrapperCompletion: (Error?) -> Void = { error in
            helpfulTimer.invalidate()
            completion(error)
        }

        if let callbacks = self.serverSyncEventHandler.userIdCallbacks[userId] {
            self.serverSyncEventHandler.userIdCallbacks[userId] = callbacks + [wrapperCompletion]
        } else {
            self.serverSyncEventHandler.userIdCallbacks[userId] = [wrapperCompletion]
        }
        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.SetUserIdJob(userId: userId))
    }

    @objc private func printHelpfulMessage() {
        print("[PushNotifications] - It looks like setUserId hasn't completed yet -- have you called `registerDeviceToken`?")
    }

    /**
     Disable Beams service.

     This will remove everything associated with the Beams from the device and Beams server.
     - Parameter completion: The block to execute after the device has been deleted from the server.
     */
    /// - Tag: stop
    @objc public func stop(completion: @escaping () -> Void) {
        let hadAnyInterests: Bool = InstanceDeviceStateStore.synchronize {
            let hadAnyInterests = self.deviceStateStore.getInterests()?.isEmpty ?? false
            self.deviceStateStore.removeAllInterests()

            return hadAnyInterests
        }

        if hadAnyInterests {
            self.interestsSetOnDeviceDidChange()
        }

        self.deviceStateStore.removeStartJobHasBeenEnqueued()
        self.deviceStateStore.removeUserIdHasBeenCalledWith()

        startHasBeenCalledThisSession = false

        self.serverSyncEventHandler.stopCallbacks.append(completion)
        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.StopJob)
    }

    /**
     Clears all the state on the SDK leaving it in the empty started state.

     This will remove the current user and all the interests associated with it from the device and Beams server.
     Device is now in a fresh state, ready for new subscriptions or user being set.
     - Parameter completion: The block to execute after the device has been deleted from the server.
     */
    /// - Tag: clearAllState
    @objc public func clearAllState(completion: @escaping () -> Void) {
        let storedAPNsToken = self.deviceStateStore.getAPNsToken()
        let hasStartAlreadyBeenCalled = self.deviceStateStore.getStartJobHasBeenEnqueued()
        self.stop(completion: completion)

        if hasStartAlreadyBeenCalled {
            self.start()
            if let apnsToken = storedAPNsToken {
                // Since we already had the token, we're forcing new device creation.
                self.registerDeviceToken(apnsToken.hexStringToData()!)
            }
        }

    }

    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.

     - Precondition: `deviceToken` should not be nil.
     */
    /// - Tag: registerDeviceToken
    @objc public func registerDeviceToken(_ deviceToken: Data) {
        PushNotificationsStatic.registerDeviceToken(deviceToken)
    }

    /**
     Subscribes the device to an interest.

     - Parameter interest: Interest that you want to subscribe your device to.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: addDeviceInterest
    @objc public func addDeviceInterest(interest: String) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let interestsChanged = InstanceDeviceStateStore.synchronize {
            self.deviceStateStore.persistInterest(interest)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.SubscribeJob(interest: interest, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
        }
    }

    /**
     Sets the subscriptions state for the device.
     Any interests not in the set will be unsubscribed from, so this will replace the interest set by the one provided.

     - Parameter interests: Interests that you want to subscribe your device to.

     - Precondition: `interests` should not be nil.

     - Throws: An error of type `MultipleInvalidInterestsError`
     */
    /// - Tag: setDeviceInterests
    @objc public func setDeviceInterests(interests: [String]) throws {
        if let invalidInterests = self.validateInterestNames(interests), invalidInterests.count > 0 {
            throw MultipleInvalidInterestsError.invalidNames(invalidInterests)
        }

        let interestsChanged = InstanceDeviceStateStore.synchronize {
            self.deviceStateStore.persistInterests(interests)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.SetSubscriptions(interests: interests, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
        }
    }

    /**
     Unsubscribe the device from an interest.

     - Parameter interest: Interest that you want to unsubscribe your device from.

     - Precondition: `interest` should not be nil.

     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: removeDeviceInterest
     @objc public func removeDeviceInterest(interest: String) throws {
        guard self.validateInterestName(interest) else {
            throw InvalidInterestError.invalidName(interest)
        }

        let interestsChanged = InstanceDeviceStateStore.synchronize {
            self.deviceStateStore.removeInterest(interest: interest)
        }

        self.serverSyncHandler.sendMessage(serverSyncJob: ServerSyncJob.UnsubscribeJob(interest: interest, localInterestsChanged: interestsChanged))
        if interestsChanged {
            self.interestsSetOnDeviceDidChange()
        }
    }

    ///Unsubscribes the device from all the interests.
    /// - Tag: clearDeviceInterests
    @objc public func clearDeviceInterests() throws {
        try self.setDeviceInterests(interests: [])
    }

    /**
     Get the interest subscriptions that the device is currently subscribed to.

     - returns: Array of interests
     */
    /// - Tag: getDeviceInterests
    @objc public func getDeviceInterests() -> [String]? {
        return InstanceDeviceStateStore.synchronize {
            return self.deviceStateStore.getInterests()
        }
    }

    private func interestsSetOnDeviceDidChange() {
        guard
            let interests = self.getDeviceInterests()
        else {
            return
        }

        self.serverSyncEventHandler.handleEvent(event: .InterestsChangedEvent(interests: interests))
    }

    /**
     Handle Remote Notification.

     - Parameter userInfo: Remote Notification payload.
     */
    /// - Tag: handleNotification
    @discardableResult
    @objc public func handleNotification(userInfo: [AnyHashable: Any]) -> RemoteNotificationType {
        return PushNotificationsStatic.handleNotification(userInfo: userInfo)
    }

    private func validateInterestName(_ interest: String) -> Bool {
        let interestNameRegex = "^[a-zA-Z0-9_\\-=@,.;]{1,164}$"
        let interestNamePredicate = NSPredicate(format: "SELF MATCHES %@", interestNameRegex)
        return interestNamePredicate.evaluate(with: interest)
    }

    private func validateInterestNames(_ interests: [String]) -> [String]? {
        return interests.filter { !self.validateInterestName($0) }
    }
}

/**
 InterestsChangedDelegate protocol.
 Method `interestsSetOnDeviceDidChange(interests:)` will be called when interests set changes.
 */
@objc public protocol InterestsChangedDelegate: class {
    /**
     Tells the delegate that the device's interests subscriptions list has changed.

     - Parameter interests: The new list of interests.
     */
    /// - Tag: interestsSetOnDeviceDidChange
    func interestsSetOnDeviceDidChange(interests: [String])
}
