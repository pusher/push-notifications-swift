#if os(iOS)
import UIKit
import UserNotifications
#elseif os(OSX)
import Cocoa
import NotificationCenter
#endif
import Foundation

@objc public final class PushNotificationsStatic: NSObject {
    
    private override init() {
        // prevent other people initialising us
    }
    
    private static var instance: PushNotifications?
    internal static var tokenProvider = Dictionary<String, TokenProvider>()
    
    /**
     Start PushNotifications service.

     - Parameter instanceId: PushNotifications instance id.

     - Precondition: `instanceId` should not be nil.
     */
    /// - Tag: start
    @objc public static func start(instanceId: String) {
        if (instance == nil) {
            instance = PushNotifications(instanceId: instanceId)
        } else if self.instance!.instanceId != instanceId {
            print("PushNotifications.shared.start has been called before with a different instance id! before: \(self.instance!.instanceId), now: \(instanceId).")
            print("If you want to use multiple instances, use `PushNotifications(instanceId: instanceId)` directly. For example:")
            print("```")
            print("   let pushNotifications1 = PushNotifications(instanceId: instanceId)")
            print("   pushNotifications1.start()")
            print("```")
        }
        instance?.start()
    }
    
    /**
     Register to receive remote notifications via Apple Push Notification service.

     Convenience method is using `.alert`, `.sound`, and `.badge` as default authorization options.

     - SeeAlso:  `registerForRemoteNotifications(options:)`
     */
    /// - Tag: register
    @objc public static func registerForRemoteNotifications() {
        self.registerForPushNotifications(options: [.alert, .sound, .badge])
    }
    
    #if os(iOS)
    /**
     Register to receive remote notifications via Apple Push Notification service.
     
     - Parameter options: The authorization options your app is requesting. You may combine the available constants to request authorization for multiple items. Request only the authorization options that you plan to use. For a list of possible values, see [UNAuthorizationOptions](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions).
     */
    /// - Tag: registerOptions
    @objc public static func registerForRemoteNotifications(options: UNAuthorizationOptions) {
        self.registerForPushNotifications(options: options)
    }
    #elseif os(OSX)
    /**
     Register to receive remote notifications via Apple Push Notification service.
     
     - Parameter options: A bit mask specifying the types of notifications the app accepts. See [NSApplication.RemoteNotificationType](https://developer.apple.com/documentation/appkit/nsapplication.remotenotificationtype) for valid bit-mask values.
     */
    @objc public static func registerForRemoteNotifications(options: NSApplication.RemoteNotificationType) {
        self.registerForPushNotifications(options: options)
    }
    #endif
    
    #if os(iOS)
    private static func registerForPushNotifications(options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("[PushNotifications] - \(error.localizedDescription)")
            }
        }
    }
    #elseif os(OSX)
    private static func registerForPushNotifications(options: NSApplication.RemoteNotificationType) {
        NSApplication.shared.registerForRemoteNotifications(matching: options)
    }
    #endif
    
    /**
     Set user id.
     
     - Parameter userId: User id.
     - Parameter tokenProvider: Token provider that will be used to generate the token for the user that you want to authenticate.
     - Parameter completion: The block to execute after attempt to set user id has been made.
     */
    /// - Tag: setUserId
    @objc public static func setUserId(_ userId: String, tokenProvider: TokenProvider, completion: @escaping (Error?) -> Void) {
        if let staticInstance = instance {
            staticInstance.setUserId(userId, tokenProvider: tokenProvider, completion: completion)
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
        }
    }
    
    /**
     Disable Beams service.
     
     This will remove everything associated with the Beams from the device and Beams server.
     - Parameter completion: The block to execute after the device has been deleted from the server.
     */
    /// - Tag: stop
    @objc public static func stop(completion: @escaping () -> Void) {
        let instances = DeviceStateStore().getInstanceIds()
        let dispatchGroup = DispatchGroup()

        for instance in instances {
            dispatchGroup.enter()
            PushNotifications(instanceId: instance).stop(completion: dispatchGroup.leave)
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    /**
     Clears all the state on the SDK leaving it in the empty started state.
     
     This will remove the current user and all the interests associated with it from the device and Beams server.
     Device is now in a fresh state, ready for new subscriptions or user being set.
     - Parameter completion: The block to execute after the device has been deleted from the server.
     */
    /// - Tag: clearAllState
    @objc public static func clearAllState(completion: @escaping () -> Void) {
        let instances = DeviceStateStore().getInstanceIds()
        let dispatchGroup = DispatchGroup()

        for instance in instances {
            dispatchGroup.enter()
            PushNotifications(instanceId: instance).clearAllState(completion: dispatchGroup.leave)
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    /**
     Register device token with PushNotifications service.
     
     - Parameter deviceToken: A token that identifies the device to APNs.
     
     - Precondition: `deviceToken` should not be nil.
     */
    /// - Tag: registerDeviceToken
    @objc public static func registerDeviceToken(_ deviceToken: Data) {
        let instances = DeviceStateStore().getInstanceIds()
        var hasAnInstanceBeenStarted = false
        
        for instance in instances {
            let instanceDeviceStateStore = InstanceDeviceStateStore(instance)
            if instanceDeviceStateStore.getStartJobHasBeenEnqueued() {
                hasAnInstanceBeenStarted = true
                instanceDeviceStateStore.persistAPNsToken(token: deviceToken.hexadecimalRepresentation())
                
                // TODO: Handle Token Refresh support
                ServerSyncProcessHandler.obtain(instanceId: instance)?
                    .sendMessage(serverSyncJob: ServerSyncJob.StartJob(instanceId: instance, token: deviceToken.hexadecimalRepresentation()))
            }
        }
        
        if !hasAnInstanceBeenStarted {
             print("[PushNotifications] - Something went wrong. Please make sure that you've called `start` before `registerDeviceToken`.")
        }
    }
    
    /**
     Subscribes the device to an interest.
     
     - Parameter interest: Interest that you want to subscribe your device to.
     
     - Precondition: `interest` should not be nil.
     
     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: addDeviceInterest
    @objc public static func addDeviceInterest(interest: String) throws {
        if let staticInstance = instance {
            try staticInstance.addDeviceInterest(interest: interest)
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
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
    @objc public static func setDeviceInterests(interests: [String]) throws {
        if let staticInstance = instance {
            try staticInstance.setDeviceInterests(interests: interests)
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
        }
    }
    
    /**
     Unsubscribe the device from an interest.
     
     - Parameter interest: Interest that you want to unsubscribe your device from.
     
     - Precondition: `interest` should not be nil.
     
     - Throws: An error of type `InvalidInterestError`
     */
    /// - Tag: removeDeviceInterest
    @objc public static func removeDeviceInterest(interest: String) throws {
        if let staticInstance = instance {
            try staticInstance.removeDeviceInterest(interest: interest)
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
        }
    }
    
    ///Unsubscribes the device from all the interests.
    /// - Tag: clearDeviceInterests
    @objc public static func clearDeviceInterests() throws {
        if let staticInstance = instance {
            try staticInstance.clearDeviceInterests()
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
        }
    }
    
    /**
     Get the interest subscriptions that the device is currently subscribed to.
     
     - returns: Array of interests
     */
    /// - Tag: getDeviceInterests
    @objc public static func getDeviceInterests() -> [String]? {
        if let staticInstance = instance {
            return staticInstance.getDeviceInterests()
        } else {
            fatalError("PushNotifications.shared.start must have been called first")
        }
    }
    
    /**
     Handle Remote Notification.
     
     - Parameter userInfo: Remote Notification payload.
     */
    /// - Tag: handleNotification
    @discardableResult
    @objc public static func handleNotification(userInfo: [AnyHashable: Any]) -> RemoteNotificationType {
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
        
        let serverSyncProcessHandler = ServerSyncProcessHandler.obtain(instanceId: eventType.getInstanceId())
        serverSyncProcessHandler?.sendMessage(serverSyncJob: .ReportEventJob(eventType: eventType))
        
        return EventTypeHandler.getRemoteNotificationType(userInfo)
    }
}
