#if os(iOS)
import UIKit
#endif
import Foundation

struct EventTypeHandler {
    // We have intentionally duplicated the code of the `getNotificationEventType` method in order to support Xcode 9 and Xcode 10.
    #if os(iOS) && swift(>=4.2)
    static func getNotificationEventType(userInfo: [AnyHashable: Any], applicationState: UIApplication.State) -> ReportEventType? {
        var eventType: ReportEventType
        let timestampSecs = UInt(Date().timeIntervalSince1970)
        let hasDisplayableContent = EventTypeHandler.hasDisplayableContent(userInfo)
        let hasData = EventTypeHandler.hasData(userInfo)

        guard
            let instanceId = InstanceId(userInfo: userInfo)?.id,
            let publishId = PublishId(userInfo: userInfo).id
        else {
            return nil
        }
        
        let deviceStateStore = InstanceDeviceStateStore(instanceId)
        guard let deviceId = deviceStateStore.getDeviceId() else {
            return nil
        }

        let userId = deviceStateStore.getUserId()

        switch applicationState {
        case .active:
            eventType = DeliveryEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs, appInBackground: false, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .background:
            eventType = DeliveryEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs, appInBackground: true, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .inactive:
            eventType = OpenEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs)
        }

        return eventType
    }
    #elseif os(iOS) && (swift(>=4.0) && !swift(>=4.2))
    static func getNotificationEventType(userInfo: [AnyHashable: Any], applicationState: UIApplicationState) -> ReportEventType? {
        var eventType: ReportEventType
        let timestampSecs = UInt(Date().timeIntervalSince1970)
        let hasDisplayableContent = EventTypeHandler.hasDisplayableContent(userInfo)
        let hasData = EventTypeHandler.hasData(userInfo)

        guard
            let instanceId = InstanceId(userInfo: userInfo)?.id,
            let publishId = PublishId(userInfo: userInfo).id
        else {
            return nil
        }
        
        let deviceStateStore = InstanceDeviceStateStore(instanceId)
        guard let deviceId = deviceStateStore.getDeviceId() else {
            return nil
        }

        let userId = deviceStateStore.getUserId()

        switch applicationState {
        case .active:
            eventType = DeliveryEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs, appInBackground: false, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .background:
            eventType = DeliveryEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs, appInBackground: true, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .inactive:
            eventType = OpenEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs)
        }

        return eventType
    }
    #endif
    #if os(OSX)
    static func getNotificationEventType(userInfo: [AnyHashable: Any]) -> OpenEventType? {
        let timestampSecs = UInt(Date().timeIntervalSince1970)
        guard
            let instanceId = InstanceId(userInfo: userInfo)?.id,
            let publishId = PublishId(userInfo: userInfo).id
        else {
            return nil
        }
        
        let deviceStateStore = InstanceDeviceStateStore(instanceId)
        guard let deviceId = deviceStateStore.getDeviceId() else {
            return nil
        }

        let userId = deviceStateStore.getUserId()

        return OpenEventType(instanceId: instanceId, publishId: publishId, deviceId: deviceId, userId: userId, timestampSecs: timestampSecs)
    }
    #endif

    static func hasDisplayableContent(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            return false
        }

        return aps["alert"] != nil
    }

    // Example APNs payload:
    //
    //  aps: {
    //    alert: {
    //      title: 'Hello',
    //      body: 'Hello, world!'
    //    },
    //    "content-available" : 1
    //  },
    //  data: {
    //    pusher: {
    //      publishId: 'pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df'
    //    }
    //  }
    //
    static func hasData(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let data = userInfo["data"] as? [String: Any] else {
            return false
        }

        // `data` will always contain at least `pusher` object.
        // Returns `true` if there is any additional information provided.
        return data.count > 1
    }

    static func getRemoteNotificationType(_ userInfo: [AnyHashable: Any]) -> RemoteNotificationType {
        guard
            let data = userInfo["data"] as? [String: Any],
            let pusher = data["pusher"] as? [String: Any]
        else {
            return .ShouldProcess
        }

        #if os(iOS) && swift(>=4.0)
        let isForeground = UIApplication.shared.applicationState != .background
        #elseif os(OSX)
        let isForeground = true
        #endif

        let hasCustomerData = data.count > 1 // checks if there's anything other than the `pusher` key

        if (hasCustomerData && isForeground) {
            return .ShouldProcess
        }

        return pusher["userShouldIgnore"] != nil ? .ShouldIgnore : .ShouldProcess
    }
}
