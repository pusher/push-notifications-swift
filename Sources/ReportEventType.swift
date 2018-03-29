import Foundation

protocol ReportEventType: Encodable {}

struct OpenEventType: ReportEventType {
    let event: String
    let publishId: String
    let deviceId: String
    let timestampSecs: UInt

    init(event: String = "Open", publishId: String, deviceId: String, timestampSecs: UInt) {
        self.event = event
        self.publishId = publishId
        self.deviceId = deviceId
        self.timestampSecs = timestampSecs
    }
}

struct DeliveryEventType: ReportEventType {
    let event: String
    let publishId: String
    let deviceId: String
    let timestampSecs: UInt
    let appInBackground: Bool
    let hasDisplayableContent: Bool
    let hasData: Bool

    init(event: String = "Delivery", publishId: String, deviceId: String, timestampSecs: UInt, appInBackground: Bool, hasDisplayableContent: Bool, hasData: Bool) {
        self.event = event
        self.publishId = publishId
        self.deviceId = deviceId
        self.timestampSecs = timestampSecs
        self.appInBackground = appInBackground
        self.hasDisplayableContent = hasDisplayableContent
        self.hasData = hasData
    }
}
