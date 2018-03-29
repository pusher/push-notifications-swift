#if os(iOS)
import UIKit
#endif
import Foundation

struct EventTypeHandler {
    #if os(iOS)
    static func getNotificationEventType(userInfo: [AnyHashable: Any], applicationState: UIApplicationState) -> ReportEventType? {
        var eventType: ReportEventType
        let timestampSecs = UInt(Date().timeIntervalSince1970)
        let hasDisplayableContent = EventTypeHandler.hasDisplayableContent(userInfo)
        let hasData = EventTypeHandler.hasData(userInfo)

        guard
            let publishId = PublishId(userInfo: userInfo).id,
            let deviceId = Device.getDeviceId()
        else { return nil }

        switch applicationState {
        case .active:
            eventType = DeliveryEventType(publishId: publishId, deviceId: deviceId, timestampSecs: timestampSecs, appInBackground: false, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .background:
            eventType = DeliveryEventType(publishId: publishId, deviceId: deviceId, timestampSecs: timestampSecs, appInBackground: true, hasDisplayableContent: hasDisplayableContent, hasData: hasData)
        case .inactive:
            eventType = OpenEventType(publishId: publishId, deviceId: deviceId, timestampSecs: timestampSecs)
        }

        return eventType
    }
    #elseif os(OSX)
    static func getNotificationEventType(userInfo: [AnyHashable: Any]) -> ReportEventType? {
        let timestampSecs = UInt(Date().timeIntervalSince1970)
        guard
            let publishId = PublishId(userInfo: userInfo).id,
            let deviceId = Device.getDeviceId()
        else { return nil }

        return OpenEventType(publishId: publishId, deviceId: deviceId, timestampSecs: timestampSecs)
    }
    #endif

    static func hasDisplayableContent(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo["aps"] as? Dictionary<String, Any> else { return false }

        return aps["alert"] != nil
    }

    static func hasData(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let data = userInfo["data"] as? Dictionary<String, Any> else { return false }

        return data.count > 1
    }
}
