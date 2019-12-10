import Foundation

protocol ReportEventType: Encodable {
    func getInstanceId() -> String
}

struct OpenEventType: ReportEventType, Codable {
    let event: String
    let instanceId: String
    let publishId: String
    let deviceId: String
    let userId: String?
    let timestampSecs: UInt

    init(event: String = Constants.ReportEventType.open, instanceId: String, publishId: String, deviceId: String, userId: String?, timestampSecs: UInt) {
        self.event = event
        self.instanceId = instanceId
        self.publishId = publishId
        self.deviceId = deviceId
        self.userId = userId
        self.timestampSecs = timestampSecs
    }
    
    func getInstanceId() -> String {
        return self.instanceId
    }
}

struct DeliveryEventType: ReportEventType, Codable {
    let event: String
    let instanceId: String
    let publishId: String
    let deviceId: String
    let userId: String?
    let timestampSecs: UInt
    let appInBackground: Bool
    let hasDisplayableContent: Bool
    let hasData: Bool

    init(event: String = Constants.ReportEventType.delivery, instanceId: String, publishId: String, deviceId: String, userId: String?, timestampSecs: UInt, appInBackground: Bool, hasDisplayableContent: Bool, hasData: Bool) {
        self.event = event
        self.instanceId = instanceId
        self.publishId = publishId
        self.deviceId = deviceId
        self.userId = userId
        self.timestampSecs = timestampSecs
        self.appInBackground = appInBackground
        self.hasDisplayableContent = hasDisplayableContent
        self.hasData = hasData
    }
    
    func getInstanceId() -> String {
        return self.instanceId
    }
}
