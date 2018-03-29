import Foundation

class ReportEventType: Encodable {
    let eventId: String
    let publishId: String
    let deviceId: String
    let timestampSecs: UInt

    init(eventId: String = "Open", publishId: String, deviceId: String, timestampSecs: UInt) {
        self.eventId = eventId
        self.publishId = publishId
        self.deviceId = deviceId
        self.timestampSecs = timestampSecs
    }
}

typealias OpenEventType = ReportEventType

class DeliveryEventType: ReportEventType {
    let appInBackground: Bool
    let hasDisplayableContent: Bool
    let hasData: Bool

    init(eventId: String = "Delivery", publishId: String, deviceId: String, timestampSecs: UInt, appInBackground: Bool, hasDisplayableContent: Bool, hasData: Bool) {
        self.appInBackground = appInBackground
        self.hasDisplayableContent = hasDisplayableContent
        self.hasData = hasData
        super.init(eventId: eventId, publishId: publishId, deviceId: deviceId, timestampSecs: timestampSecs)
    }
}
