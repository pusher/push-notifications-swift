import XCTest
import Nimble
@testable import PushNotifications

class ReportEventTypeTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-ReportEventTypeTests".data(using: .utf8)!

    override func setUp() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testHandleNotification() {
        let pushNotifications = PushNotifications.shared
        pushNotifications.start(instanceId: instanceId)

        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)

        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]

        let eventType = pushNotifications.handleNotification(userInfo: userInfo)
        XCTAssertEqual(eventType, .ShouldProcess)
    }
}
